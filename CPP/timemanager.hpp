#pragma once
#include <iostream>
#include <chrono>

using namespace std::chrono::_V2;

class TimeManager{
private:
    double _total_time;
    system_clock::time_point _time_point;
    bool _is_started();
    int _time_type;
public:
    bool is_started();
    void start(int time_type = 0);
    void pause();
    double finish();
};