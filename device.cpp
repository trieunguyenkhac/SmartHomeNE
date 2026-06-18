#include "device.h"

Device::Device(QObject *parent) : QObject(parent), m_targetTemp(24.0), m_fanSpeed(3), m_mode("cool") {}

Device::Device(QString id, QString name, QString type, bool status, double powerUsage, QObject *parent)
    : QObject(parent), m_id(id), m_name(name), m_type(type), m_status(status), m_currentPowerUsage(powerUsage) {}

void Device::setId(const QString &id) {
    if (m_id != id) {
        m_id = id;
        emit idChanged();
    }
}

void Device::setName(const QString &name) {
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

void Device::setType(const QString &type) {
    if (m_type != type) {
        m_type = type;
        emit typeChanged();
    }
}

void Device::setStatus(bool status) {
    if (m_status != status) {
        m_status = status;
        emit statusChanged();
        if (!status) {
            setCurrentPowerUsage(0.0);
        }
    }
}

void Device::setCurrentPowerUsage(double power) {
    if (qAbs(m_currentPowerUsage - power) > 0.001) {
        m_currentPowerUsage = power;
        emit currentPowerUsageChanged();
    }
}

void Device::setTotalKwh(double kwh) {
    if (qAbs(m_totalKwh - kwh) > 0.001) {
        m_totalKwh = kwh;
        emit totalKwhChanged();
    }
}

void Device::setTargetTemp(double temp) {
    if (qAbs(m_targetTemp - temp) > 0.001) {
        m_targetTemp = temp;
        emit targetTempChanged();
    }
}

void Device::setFanSpeed(int speed) {
    if (m_fanSpeed != speed) {
        m_fanSpeed = speed;
        emit fanSpeedChanged();
    }
}

void Device::setMode(const QString &mode) {
    if (m_mode != mode) {
        m_mode = mode;
        emit modeChanged();
    }
}
