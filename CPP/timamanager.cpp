#include "timemanager.hpp"


void TimeManager::start(int time_type){
    _time_point = std::chrono::high_resolution_clock::now();
    _is_started = true;
}

double TimeManager::finish(){
    if (_is_started)
    {
        _is_started = false;
        return double((std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::high_resolution_clock::now() - _time_point)).count())/1000000.0;
    }
    else
    {
        cerr << "Time is not started yet!";
    }
}