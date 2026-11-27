// HMOOD__TG@i_8_f

#ifndef INI_RW
#define INI_RW

typedef struct ini INI;

INI *ini_load(const char *path);
char *ini_read(INI *ini, const char *section, const char *item);
int ini_write(INI *ini, const char *section, const char *item, const char *value);
int ini_remove(INI *ini, const char *section, const char *item);

namespace configManager {
    int readInteger(INI *config, const char *section, const char *key, int deValue);
    float readFloat(INI *config, const char *section, const char *key, float deValue);
    bool readBoolean(INI *config, const char *section, const char *key, bool deValue);

    void putInteger(INI *config, const char *section, const char *key, int value);
    void putFloat(INI *config, const char *section, const char *key, float value);
    void putBoolean(INI *config, const char *section, const char *key, bool value);
}

#endif
