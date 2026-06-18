#include "room.h"

Room::Room(QObject *parent) : QObject(parent) {}

Room::Room(QString name, double totalEnergy, double temperature, QObject *parent)
    : QObject(parent), m_roomName(name), m_totalEnergy(totalEnergy), m_temperature(temperature) {}

void Room::setRoomName(const QString &name) {
    if (m_roomName != name) {
        m_roomName = name;
        emit roomNameChanged();
    }
}

void Room::setTotalEnergy(double energy) {
    if (qAbs(m_totalEnergy - energy) > 0.001) {
        m_totalEnergy = energy;
        emit totalEnergyChanged();
    }
}

void Room::setTemperature(double temp) {
    if (qAbs(m_temperature - temp) > 0.001) {
        m_temperature = temp;
        emit temperatureChanged();
    }
}

void Room::addDevice(Device* device) {
    device->setParent(this);
    m_devices.append(device);
    emit devicesChanged();
}

QQmlListProperty<Device> Room::devices() {
    return QQmlListProperty<Device>(this, this,
             &Room::appendDevice,
             &Room::deviceCount,
             &Room::deviceAt,
             &Room::clearDevices);
}

void Room::appendDevice(QQmlListProperty<Device> *list, Device *device) {
    Room *room = qobject_cast<Room*>(list->object);
    if (room && device) {
        room->m_devices.append(device);
        emit room->devicesChanged();
    }
}

qsizetype Room::deviceCount(QQmlListProperty<Device> *list) {
    Room *room = qobject_cast<Room*>(list->object);
    return room ? room->m_devices.count() : 0;
}

Device* Room::deviceAt(QQmlListProperty<Device> *list, qsizetype index) {
    Room *room = qobject_cast<Room*>(list->object);
    if (room && index >= 0 && index < room->m_devices.count()) {
        return room->m_devices.at(index);
    }
    return nullptr;
}

void Room::clearDevices(QQmlListProperty<Device> *list) {
    Room *room = qobject_cast<Room*>(list->object);
    if (room) {
        room->m_devices.clear();
        emit room->devicesChanged();
    }
}
