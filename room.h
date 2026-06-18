#ifndef ROOM_H
#define ROOM_H

#include <QObject>
#include <QString>
#include <QList>
#include <QQmlListProperty>
#include "device.h"

class Room : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString roomName READ roomName WRITE setRoomName NOTIFY roomNameChanged)
    Q_PROPERTY(double totalEnergy READ totalEnergy WRITE setTotalEnergy NOTIFY totalEnergyChanged)
    Q_PROPERTY(double temperature READ temperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(QQmlListProperty<Device> devices READ devices)

public:
    explicit Room(QObject *parent = nullptr);
    Room(QString name, double totalEnergy, double temperature, QObject *parent = nullptr);

    QString roomName() const { return m_roomName; }
    void setRoomName(const QString &name);

    double totalEnergy() const { return m_totalEnergy; }
    void setTotalEnergy(double energy);

    double temperature() const { return m_temperature; }
    void setTemperature(double temp);

    QQmlListProperty<Device> devices();
    QList<Device*> deviceList() const { return m_devices; }
    QList<Device*>& deviceListRef() { return m_devices; }

    void addDevice(Device* device);

signals:
    void roomNameChanged();
    void totalEnergyChanged();
    void temperatureChanged();
    void devicesChanged();

private:
    static void appendDevice(QQmlListProperty<Device> *list, Device *device);
    static qsizetype deviceCount(QQmlListProperty<Device> *list);
    static Device* deviceAt(QQmlListProperty<Device> *list, qsizetype index);
    static void clearDevices(QQmlListProperty<Device> *list);

    QString m_roomName;
    double m_totalEnergy = 0.0;
    double m_temperature = 24.0;
    QList<Device*> m_devices;
};

#endif // ROOM_H
