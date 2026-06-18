#include "homemanager.h"
#include <QDateTime>

HomeManager* HomeManager::m_instance = nullptr;

HomeManager* HomeManager::instance() {
    if (!m_instance) {
        m_instance = new HomeManager();
    }
    return m_instance;
}

HomeManager::HomeManager(QObject *parent) : QObject(parent) {
    setupInitialData();
}

void HomeManager::setupInitialData() {
    // Room 0: Phòng ngủ
    Room *br = new Room("Phòng ngủ", 4.1, 24.0, this);
    Device *brAc = new Device("br_ac", "Điều hòa phòng ngủ", "ac", true, 850.0, this);
    brAc->setTargetTemp(24.0);
    br->addDevice(brAc);
    br->addDevice(new Device("br_light", "Đèn đọc sách", "light", false, 8.0, this));
    m_rooms.append(br);

    // Room 1: Nhà bếp
    Room *kt = new Room("Nhà bếp", 2.5, 27.0, this);
    kt->addDevice(new Device("kt_light", "Đèn bếp", "light", true, 12.0, this));
    kt->addDevice(new Device("kt_fridge", "Tủ lạnh", "tv", true, 150.0, this));
    m_rooms.append(kt);

    // Room 2: Phòng khách
    Room *lr = new Room("Phòng khách", 7.2, 26.0, this);
    lr->addDevice(new Device("lr_light", "Đèn trần", "light", true, 10.0, this));
    lr->addDevice(new Device("lr_fan", "Quạt đứng", "fan", true, 45.0, this));
    lr->addDevice(new Device("lr_tv", "Tivi", "tv", false, 120.0, this));
    Device *lrAc = new Device("lr_ac", "Điều hòa", "ac", true, 900.0, this);
    lrAc->setTargetTemp(24.0);
    lr->addDevice(lrAc);
    m_rooms.append(lr);

    m_alerts.append("Điều hòa phòng khách đã bật trên 8 giờ (01:15)");
    m_alerts.append("Tiêu thụ điện vượt ngưỡng cảnh báo (+20% hôm nay)");
}

// ── QML-facing helpers ────────────────────────────────────────────────────────

QVariantMap HomeManager::deviceToMap(Device *dev, const QString &roomName) const {
    QVariantMap m;
    m["name"]         = dev->name();
    m["room"]         = roomName;
    m["isOn"]         = dev->status();
    m["wattHour"]     = qRound(dev->currentPowerUsage());   // W
    m["usageMinutes"] = qRound(dev->totalKwh() * 60.0);     // approximate minutes from kWh
    m["energyKWh"]    = QString::number(dev->totalKwh(), 'f', 4);
    m["type"]         = dev->type();
    m["id"]           = dev->id();
    return m;
}

QVariantList HomeManager::getDevices(int roomIndex) const {
    QVariantList result;
    if (roomIndex < 0) {
        // All rooms
        for (Room *room : m_rooms) {
            for (Device *dev : room->deviceList()) {
                result.append(deviceToMap(dev, room->roomName()));
            }
        }
    } else if (roomIndex < m_rooms.size()) {
        Room *room = m_rooms.at(roomIndex);
        for (Device *dev : room->deviceList()) {
            result.append(deviceToMap(dev, room->roomName()));
        }
    }
    return result;
}

void HomeManager::toggleDevice(const QString &name) {
    Device *dev = findDeviceByName(name);
    if (dev) {
        dev->setStatus(!dev->status());
        emit activeDevicesCountChanged();
        emit deviceListChanged();
    }
}

bool HomeManager::addDevice(const QString &name, double watts, int roomIndex) {
    // Check duplicate name
    if (findDeviceByName(name)) return false;
    if (roomIndex < 0 || roomIndex >= m_rooms.size()) return false;

    QString id = name.toLower().replace(' ', '_') + QString::number(QDateTime::currentMSecsSinceEpoch() % 10000);
    Device *dev = new Device(id, name, "light", false, watts, this);
    m_rooms.at(roomIndex)->addDevice(dev);
    emit deviceListChanged();
    return true;
}

void HomeManager::removeDevice(const QString &name) {
    for (Room *room : m_rooms) {
        QList<Device*> &list = room->deviceListRef();
        for (int i = 0; i < list.size(); ++i) {
            if (list.at(i)->name() == name) {
                Device *dev = list.takeAt(i);
                dev->deleteLater();
                emit deviceListChanged();
                return;
            }
        }
    }
}

double HomeManager::energyByRoom(int roomIndex) const {
    if (roomIndex >= 0 && roomIndex < m_rooms.size()) {
        return m_rooms.at(roomIndex)->totalEnergy();
    }
    return 0.0;
}

QVariantList HomeManager::checkAlerts() const {
    QVariantList result;
    // Alert if a device has been on long (simulated: totalKwh > 0.5 kWh)
    for (Room *room : m_rooms) {
        for (Device *dev : room->deviceList()) {
            if (dev->status() && dev->totalKwh() > 0.5) {
                QVariantMap alert;
                alert["message"] = QString("⚠️ %1 (%2) tiêu thụ %.2f kWh")
                                       .arg(dev->name(), room->roomName())
                                       .arg(dev->totalKwh());
                result.append(alert);
            }
        }
    }
    // Also include standing alerts
    for (const QString &msg : m_alerts) {
        QVariantMap alert;
        alert["message"] = msg;
        result.append(alert);
    }
    return result;
}

Device* HomeManager::findDeviceByName(const QString &name) const {
    for (Room *room : m_rooms) {
        for (Device *dev : room->deviceList()) {
            if (dev->name() == name) return dev;
        }
    }
    return nullptr;
}

// ── Standard property setters ────────────────────────────────────────────────

void HomeManager::setTotalHomeEnergyToday(double energy) {
    if (qAbs(m_totalHomeEnergyToday - energy) > 0.001) {
        m_totalHomeEnergyToday = energy;
        emit totalHomeEnergyTodayChanged();
    }
}

void HomeManager::setCostToday(double cost) {
    if (qAbs(m_costToday - cost) > 0.001) {
        m_costToday = cost;
        emit costTodayChanged();
    }
}

int HomeManager::activeDevicesCount() const {
    int count = 0;
    for (Room *room : m_rooms) {
        for (Device *dev : room->deviceList()) {
            if (dev->status()) count++;
        }
    }
    return count;
}

double HomeManager::currentTotalWatt() const {
    double total = 0.0;
    for (Room *room : m_rooms) {
        for (Device *dev : room->deviceList()) {
            if (dev->status()) total += dev->currentPowerUsage();
        }
    }
    return total;
}

void HomeManager::setAlerts(const QList<QString> &alerts) {
    m_alerts = alerts;
    emit alertsChanged();
}

void HomeManager::addAlert(const QString &alert) {
    m_alerts.insert(0, alert);
    emit alertsChanged();
}

// ── QQmlListProperty callbacks ───────────────────────────────────────────────

QQmlListProperty<Room> HomeManager::rooms() {
    return QQmlListProperty<Room>(this, this,
             &HomeManager::appendRoom,
             &HomeManager::roomCount,
             &HomeManager::roomAt,
             &HomeManager::clearRooms);
}

void HomeManager::appendRoom(QQmlListProperty<Room> *list, Room *room) {
    HomeManager *hm = qobject_cast<HomeManager*>(list->object);
    if (hm && room) {
        hm->m_rooms.append(room);
        emit hm->alertsChanged();
    }
}

qsizetype HomeManager::roomCount(QQmlListProperty<Room> *list) {
    HomeManager *hm = qobject_cast<HomeManager*>(list->object);
    return hm ? hm->m_rooms.count() : 0;
}

Room* HomeManager::roomAt(QQmlListProperty<Room> *list, qsizetype index) {
    HomeManager *hm = qobject_cast<HomeManager*>(list->object);
    if (hm && index >= 0 && index < hm->m_rooms.count()) {
        return hm->m_rooms.at(index);
    }
    return nullptr;
}

void HomeManager::clearRooms(QQmlListProperty<Room> *list) {
    HomeManager *hm = qobject_cast<HomeManager*>(list->object);
    if (hm) {
        hm->m_rooms.clear();
        emit hm->alertsChanged();
    }
}
