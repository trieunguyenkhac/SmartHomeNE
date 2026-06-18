#ifndef HOMEMANAGER_H
#define HOMEMANAGER_H

#include <QObject>
#include <QList>
#include <QVariant>
#include <QVariantList>
#include <QVariantMap>
#include <QQmlListProperty>
#include "room.h"

class HomeManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<Room> rooms READ rooms)
    Q_PROPERTY(double totalHomeEnergyToday READ totalHomeEnergyToday WRITE setTotalHomeEnergyToday NOTIFY totalHomeEnergyTodayChanged)
    Q_PROPERTY(double costToday READ costToday WRITE setCostToday NOTIFY costTodayChanged)
    Q_PROPERTY(int activeDevicesCount READ activeDevicesCount NOTIFY activeDevicesCountChanged)
    Q_PROPERTY(double currentTotalWatt READ currentTotalWatt NOTIFY currentTotalWattChanged)
    Q_PROPERTY(QList<QString> alerts READ alerts WRITE setAlerts NOTIFY alertsChanged)

public:
    static HomeManager* instance();

    QQmlListProperty<Room> rooms();
    QList<Room*> roomList() const { return m_rooms; }

    double totalHomeEnergyToday() const { return m_totalHomeEnergyToday; }
    void setTotalHomeEnergyToday(double energy);

    double costToday() const { return m_costToday; }
    void setCostToday(double cost);

    int activeDevicesCount() const;
    double currentTotalWatt() const;

    QList<QString> alerts() const { return m_alerts; }
    void setAlerts(const QList<QString> &alerts);
    void addAlert(const QString &alert);

    // ── Methods called by QML via "homeManager" context property ──

    // Returns list of device maps for given roomIndex (-1 = all rooms)
    Q_INVOKABLE QVariantList getDevices(int roomIndex) const;

    // Toggle device on/off by name
    Q_INVOKABLE void toggleDevice(const QString &name);

    // Add a new device; returns false if name already exists
    Q_INVOKABLE bool addDevice(const QString &name, double watts, int roomIndex);

    // Remove a device by name
    Q_INVOKABLE void removeDevice(const QString &name);

    // Returns total energy (kWh) consumed today
    Q_INVOKABLE double totalEnergy() const { return m_totalHomeEnergyToday; }

    // Returns total energy (kWh) for a specific room
    Q_INVOKABLE double energyByRoom(int roomIndex) const;

    // Returns list of alert maps (key: "message")
    Q_INVOKABLE QVariantList checkAlerts() const;

signals:
    void totalHomeEnergyTodayChanged();
    void costTodayChanged();
    void activeDevicesCountChanged();
    void currentTotalWattChanged();
    void alertsChanged();
    void deviceListChanged();   // QML listens: onDeviceListChanged
    void alertMessage(const QString &msg); // QML listens: onAlertMessage

private:
    explicit HomeManager(QObject *parent = nullptr);
    void setupInitialData();

    // Helper: find device by name across all rooms
    Device* findDeviceByName(const QString &name) const;
    // Helper: build a QVariantMap from a Device + room name
    QVariantMap deviceToMap(Device *dev, const QString &roomName) const;

    static void appendRoom(QQmlListProperty<Room> *list, Room *room);
    static qsizetype roomCount(QQmlListProperty<Room> *list);
    static Room* roomAt(QQmlListProperty<Room> *list, qsizetype index);
    static void clearRooms(QQmlListProperty<Room> *list);

    static HomeManager* m_instance;
    QList<Room*> m_rooms;
    double m_totalHomeEnergyToday = 18.7;
    double m_costToday = 45500.0;
    QList<QString> m_alerts;
};

#endif // HOMEMANAGER_H
