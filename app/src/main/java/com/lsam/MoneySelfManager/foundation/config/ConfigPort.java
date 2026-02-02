package com.lsam.MoneySelfManager.foundation.config;

public interface ConfigPort {
    String getString(String key, String defVal);
    void putString(String key, String value);
}
