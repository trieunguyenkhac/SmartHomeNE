#ifndef SIMULATIONENGINE_H
#define SIMULATIONENGINE_H

#include <QObject>
#include <QTimer>
#include "homemanager.h"

class SimulationEngine : public QObject
{
    Q_OBJECT
public:
    explicit SimulationEngine(HomeManager *manager, QObject *parent = nullptr);
    void start();
    void stop();

private slots:
    void onTick();

private:
    HomeManager *m_manager;
    QTimer *m_timer;
};

#endif // SIMULATIONENGINE_H
