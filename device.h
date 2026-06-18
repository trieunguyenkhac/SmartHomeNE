#ifndef DEVICE_H
#define DEVICE_H

#include <QObject>
#include <QString>

class Device : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(bool status READ status WRITE setStatus NOTIFY statusChanged)
    Q_PROPERTY(double currentPowerUsage READ currentPowerUsage WRITE setCurrentPowerUsage NOTIFY currentPowerUsageChanged)
    Q_PROPERTY(double totalKwh READ totalKwh WRITE setTotalKwh NOTIFY totalKwhChanged)
    Q_PROPERTY(double targetTemp READ targetTemp WRITE setTargetTemp NOTIFY targetTempChanged)
    Q_PROPERTY(int fanSpeed READ fanSpeed WRITE setFanSpeed NOTIFY fanSpeedChanged)
    Q_PROPERTY(QString mode READ mode WRITE setMode NOTIFY modeChanged)

public:
    explicit Device(QObject *parent = nullptr);
    Device(QString id, QString name, QString type, bool status, double powerUsage, QObject *parent = nullptr);

    QString id() const { return m_id; }
    void setId(const QString &id);

    QString name() const { return m_name; }
    void setName(const QString &name);

    QString type() const { return m_type; }
    void setType(const QString &type);

    bool status() const { return m_status; }
    void setStatus(bool status);

    double currentPowerUsage() const { return m_currentPowerUsage; }
    void setCurrentPowerUsage(double power);

    double totalKwh() const { return m_totalKwh; }
    void setTotalKwh(double kwh);

    double targetTemp() const { return m_targetTemp; }
    void setTargetTemp(double temp);

    int fanSpeed() const { return m_fanSpeed; }
    void setFanSpeed(int speed);

    QString mode() const { return m_mode; }
    void setMode(const QString &mode);

signals:
    void idChanged();
    void nameChanged();
    void typeChanged();
    void statusChanged();
    void currentPowerUsageChanged();
    void totalKwhChanged();
    void targetTempChanged();
    void fanSpeedChanged();
    void modeChanged();

private:
    QString m_id;
    QString m_name;
    QString m_type;
    bool m_status = false;
    double m_currentPowerUsage = 0.0;
    double m_totalKwh = 0.0;
    double m_targetTemp = 24.0;
    int m_fanSpeed = 3;
    QString m_mode = "cool";
};

#endif // DEVICE_H
