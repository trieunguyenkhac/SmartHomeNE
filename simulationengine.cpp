#include "simulationengine.h"
#include <QRandomGenerator>

SimulationEngine::SimulationEngine(HomeManager *manager, QObject *parent)
    : QObject(parent), m_manager(manager)
{
    m_timer = new QTimer(this);
    connect(m_timer, &QTimer::timeout, this, &SimulationEngine::onTick);
}

void SimulationEngine::start() {
    m_timer->start(2000); // Trigger every 2 seconds
}

void SimulationEngine::stop() {
    m_timer->stop();
}

void SimulationEngine::onTick() {
    double energyAddedSum = 0.0;
    bool stateChanged = false;

    for (Room* room : m_manager->roomList()) {
        double roomInitialEnergy = room->totalEnergy();
        double activeWatts = 0.0;

        for (Device* dev : room->deviceList()) {
            if (dev->status()) {
                // If it is turned ON, simulate subtle fluctuations
                double power = dev->currentPowerUsage();
                double randCoeff = QRandomGenerator::global()->generateDouble() * 0.1 + 0.95; // 95% to 105%
                double basePower = power;
                
                // Adjust base power depending on type
                if (dev->type() == "ac") {
                    basePower = 850.0;
                    // AC power depends on ambient vs target temp difference
                    double diff = qAbs(room->temperature() - dev->targetTemp());
                    basePower = 300.0 + (diff * 150.0);
                    if (basePower > 1200.0) basePower = 1200.0;
                } else if (dev->type() == "light") {
                    basePower = 10.0;
                } else if (dev->type() == "fan") {
                    basePower = 15.0 * dev->fanSpeed();
                }

                double fluctuatedPower = basePower * randCoeff;
                dev->setCurrentPowerUsage(fluctuatedPower);

                activeWatts += fluctuatedPower;

                // Add to kwh (simulation tick = 2 seconds = 2/3600 hours)
                double addedKwh = (fluctuatedPower / 1000.0) * (2.0 / 3600.0);
                dev->setTotalKwh(dev->totalKwh() + addedKwh);
                energyAddedSum += addedKwh;
            }
        }

        // Simulate ambient room temperature approaching target AC temp or outdoor temp (30 C)
        double currentTemp = room->temperature();
        bool hasAcOn = false;
        double targetAcTemp = 24.0;
        for (Device* dev : room->deviceList()) {
            if (dev->type() == "ac" && dev->status()) {
                hasAcOn = true;
                targetAcTemp = dev->targetTemp();
                break;
            }
        }

        if (hasAcOn) {
            // Approach target AC temperature
            if (currentTemp > targetAcTemp) {
                currentTemp -= 0.1;
            } else if (currentTemp < targetAcTemp) {
                currentTemp += 0.1;
            }
        } else {
            // Leak heat towards ambient outdoor temperature (30 C)
            if (currentTemp < 30.0) {
                currentTemp += 0.05;
            }
        }
        room->setTemperature(currentTemp);

        // Update room total consumption
        double incrementalKwh = (activeWatts / 1000.0) * (2.0 / 3600.0);
        room->setTotalEnergy(roomInitialEnergy + incrementalKwh);
    }

    if (energyAddedSum > 0.0) {
        double newTotal = m_manager->totalHomeEnergyToday() + energyAddedSum;
        m_manager->setTotalHomeEnergyToday(newTotal);
        m_manager->setCostToday(newTotal * 2436.0); // 2436 VND per kWh
        emit m_manager->activeDevicesCountChanged();
        emit m_manager->deviceListChanged(); // notify QML to refresh device list
    }

    // Luôn emit để QML cập nhật công suất tức thời (W), kể cả khi không có thiết bị nào bật
    emit m_manager->currentTotalWattChanged();
}
