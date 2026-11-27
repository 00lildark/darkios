// HMOOD__TG@i_8_f

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ini_rw.h"

typedef struct section_t section_t;
typedef struct item_t item_t;

#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

#define FREE_SECTION(s) do { if (s) { free((s)->name); free(s); } } while (0)
#define FREE_ITEM(i) do { if (i) { free((i)->name); free((i)->value); free(i); } } while (0)

struct section_t {
    char *name;
    item_t *items;
    item_t *tail;
    section_t *next;
};

struct item_t {
    char *name;
    char *value;
    item_t *next;
};

struct ini {
    char **section_names;
    char **item_names;
    section_t *sections;
    section_t *tail;
    char file[PATH_MAX];
};

static char *dup_str(const char *src) {
    if (!src) src = "";
    size_t len = strlen(src);
    char *dst = (char *)malloc(len + 1);
    if (!dst) return NULL;
    memcpy(dst, src, len + 1);
    return dst;
}

static void save_file(INI *ini) {
    if (!ini || !ini->file[0]) return;
    FILE *f = fopen(ini->file, "w");
    if (!f) return;

    for (section_t *s = ini->sections; s; s = s->next) {
        fprintf(f, "[%s]\n", s->name ? s->name : "");
        for (item_t *i = s->items; i; i = i->next) {
            fprintf(f, "%s = %s\n", i->name ? i->name : "", i->value ? i->value : "");
        }
        if (s->next) {
            fputs("\n", f);
        }
    }
    fclose(f);
}

static section_t *find_section(INI *ini, const char *name) {
    if (!ini || !ini->sections || !name) {
        return NULL;
    }

    for (section_t *s = ini->sections; s; s = s->next) {
        if (s->name && strcmp(name, s->name) == 0) {
            return s;
        }
    }
    return NULL;
}

static item_t *find_item(section_t *s, const char *name) {
    if (!s || !s->items || !name) {
        return NULL;
    }

    for (item_t *i = s->items; i; i = i->next) {
        if (i->name && strcmp(name, i->name) == 0) {
            return i;
        }
    }
    return NULL;
}

static section_t *add_section(INI *ini, const char *name) {
    if (!ini) return NULL;
    const char *secName = name ? name : "";

    section_t *existing = find_section(ini, secName);
    if (existing) {
        return existing;
    }

    section_t *s = (section_t *)malloc(sizeof(section_t));
    if (!s) return NULL;
    s->name = dup_str(secName);
    if (!s->name) {
        free(s);
        return NULL;
    }
    s->next = NULL;
    s->items = NULL;
    s->tail = NULL;

    if (!ini->sections) {
        ini->sections = s;
    } else {
        ini->tail->next = s;
    }
    ini->tail = s;
    return s;
}

static int add_item(INI *ini, const char *section, const char *item, const char *value) {
    if (!ini || !item || !value) return 0;
    int r = 0;
    section_t *s = add_section(ini, section);
    if (!s) return 0;

    item_t *i = find_item(s, item);
    if (!i) {
        r++;
        i = (item_t *)malloc(sizeof(item_t));
        if (!i) return 0;
        i->name = dup_str(item);
        i->value = dup_str(value);
        i->next = NULL;
        if (!i->name || !i->value) {
            FREE_ITEM(i);
            return 0;
        }
    } else if (!i->value || strcmp(value, i->value) != 0) {
        char *newVal = dup_str(value);
        if (!newVal) return r;
        free(i->value);
        i->value = newVal;
        save_file(ini);
        return ++r;
    } else {
        return r;
    }

    if (!s->items) {
        r++;
        s->items = i;
    } else {
        s->tail->next = i;
    }
    s->tail = i;

    return r;
}

static int rm_section(INI *ini, section_t *s) {
    if (!ini || !s) return 0;
    int r = 0;

    while (s->items) {
        r++;
        item_t *i = s->items;
        s->items = i->next;
        FREE_ITEM(i);
    }

    if (s == ini->sections) {
        ini->sections = s->next;
        if (!ini->sections) {
            ini->tail = NULL;
        }
        FREE_SECTION(s);
        return ++r;
    }

    section_t *s_ = ini->sections;
    while (s_ && s_->next != s) {
        s_ = s_->next;
    }
    if (s_) {
        s_->next = s->next;
        if (!s_->next) {
            ini->tail = s_;
        }
    }
    FREE_SECTION(s);
    return ++r;
}

INI *ini_load(const char *path) {
    if (!path) return NULL;

    INI *ini = (INI *)malloc(sizeof(INI));
    if (!ini) return NULL;

    snprintf(ini->file, sizeof(ini->file), "%s", path);
    ini->sections = NULL;
    ini->section_names = NULL;
    ini->item_names = NULL;
    ini->tail = NULL;

    FILE *f = fopen(ini->file, "r");
    if (!f) {
        return ini;
    }

    if (fseek(f, 0, SEEK_END) != 0) {
        fclose(f);
        return ini;
    }
    long size = ftell(f);
    if (size <= 0 || size > 16 * 1024 * 1024) {
        fclose(f);
        return ini;
    }
    rewind(f);

    char *data = (char *)malloc((size_t)size + 1);
    if (!data) {
        fclose(f);
        return ini;
    }

    size_t readBytes = fread(data, 1, (size_t)size, f);
    data[readBytes] = '\0';
    fclose(f);

    char *r = data;
    char *line_end = NULL;
    char *current_section = NULL;

    while ((line_end = strchr(r, '\n')) != NULL) {
        *line_end = '\0';
        size_t lineLen = strlen(r);
        if (lineLen > 0 && r[lineLen - 1] == '\r') {
            r[lineLen - 1] = '\0';
        }

        const char *trim = r;
        while (*trim == ' ' || *trim == '\t') {
            trim++;
        }

        if (*trim == '\0' || *trim == ';' || *trim == '#') {
            r = line_end + 1;
            continue;
        }

        const char *secStart = strchr(trim, '[');
        const char *secEnd = secStart ? strchr(secStart + 1, ']') : NULL;
        const char *eqPos = strchr(trim, '=');

        if (secStart && secEnd && (!eqPos || secStart < eqPos)) {
            size_t secLen = (size_t)(secEnd - (secStart + 1));
            char *secBuf = (char *)malloc(secLen + 1);
            if (secBuf) {
                memcpy(secBuf, secStart + 1, secLen);
                secBuf[secLen] = '\0';
                section_t *s = add_section(ini, secBuf);
                current_section = s ? s->name : NULL;
                free(secBuf);
            }
        } else if (eqPos) {
            size_t keyLen = (size_t)(eqPos - trim);
            while (keyLen > 0 && (trim[keyLen - 1] == ' ' || trim[keyLen - 1] == '\t')) {
                keyLen--;
            }

            const char *valStart = eqPos + 1;
            while (*valStart == ' ' || *valStart == '\t') {
                valStart++;
            }
            size_t valLen = strlen(valStart);
            while (valLen > 0 && (valStart[valLen - 1] == ' ' || valStart[valLen - 1] == '\t')) {
                valLen--;
            }

            if (keyLen > 0) {
                char *keyBuf = (char *)malloc(keyLen + 1);
                char *valBuf = (char *)malloc(valLen + 1);
                if (keyBuf && valBuf) {
                    memcpy(keyBuf, trim, keyLen);
                    keyBuf[keyLen] = '\0';
                    memcpy(valBuf, valStart, valLen);
                    valBuf[valLen] = '\0';
                    add_item(ini, current_section ? current_section : "Default", keyBuf, valBuf);
                }
                free(keyBuf);
                free(valBuf);
            }
        }

        r = line_end + 1;
    }

    free(data);
    return ini;
}

char *ini_read(INI *ini, const char *section, const char *item) {
    section_t *s = find_section(ini, section);
    item_t *i = find_item(s, item);
    if (!s || !i) {
        return NULL;
    }
    return i->value;
}

int ini_write(INI *ini, const char *section, const char *item, const char *value) {
    if (!ini || !section || !item || !value) return 0;
    int r = add_item(ini, section, item, value);
    if (r) {
        save_file(ini);
    }
    return r;
}

int ini_remove(INI *ini, const char *section, const char *item) {
    if (!ini || !section) return 0;
    section_t *s = find_section(ini, section);
    if (!s) return 0;

    item_t *i = NULL;
    if (item && !(i = find_item(s, item))) {
        return 0;
    }

    if (!item || !s->items || !s->items->next) {
        int r = rm_section(ini, s);
        save_file(ini);
        return r;
    }

    if (i == s->items) {
        s->items = i->next;
        FREE_ITEM(i);
        save_file(ini);
        return 1;
    }

    item_t *i_ = s->items;
    while (i_ && i_->next != i) {
        i_ = i_->next;
    }
    if (i_) {
        i_->next = i->next;
        if (!i_->next) {
            s->tail = i_;
        }
    }
    FREE_ITEM(i);
    save_file(ini);
    return 1;
}

int configManager::readInteger(INI *config, const char *section, const char *key, int deValue) {
    char *result = ini_read(config, section, key);
    if (result == NULL) {
        return deValue;
    }
    return atoi(result);
}

float configManager::readFloat(INI *config, const char *section, const char *key, float deValue) {
    char *result = ini_read(config, section, key);
    if (result == NULL) {
        return deValue;
    }
    return (float)atof(result);
}

bool configManager::readBoolean(INI *config, const char *section, const char *key, bool deValue) {
    char *result = ini_read(config, section, key);
    if (result == NULL) {
        return deValue;
    }
    return atoi(result) != 0;
}

void configManager::putInteger(INI *config, const char *section, const char *key, int value) {
    if (!config) return;
    char buffer[32];
    snprintf(buffer, sizeof(buffer), "%d", value);
    ini_write(config, section, key, buffer);
}

void configManager::putFloat(INI *config, const char *section, const char *key, float value) {
    if (!config) return;
    char buffer[32];
    snprintf(buffer, sizeof(buffer), "%f", value);
    ini_write(config, section, key, buffer);
}

void configManager::putBoolean(INI *config, const char *section, const char *key, bool value) {
    if (!config) return;
    char buffer[2];
    snprintf(buffer, sizeof(buffer), "%d", value ? 1 : 0);
    ini_write(config, section, key, buffer);
}
