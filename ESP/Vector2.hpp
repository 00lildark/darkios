// HMOOD__TG@i_8_f

#pragma once

#define _USE_MATH_DEFINES
#include <cmath>

struct Vector2
{
    union
    {
        struct
        {
            float X;
            float Y;
        };
        float data[2];
    };

    inline Vector2();
    inline Vector2(float data[]);
    inline Vector2(float value);
    inline Vector2(float x, float y);

    static inline Vector2 Zero();
    static inline Vector2 Right();
    static inline Vector2 Left();
    static inline Vector2 Up();
    static inline Vector2 Down();

    static inline float Angle(Vector2 a, Vector2 b);
    static inline float Component(Vector2 a, Vector2 b);
    static inline float Distance(Vector2 a, Vector2 b);
    static inline float Dot(Vector2 lhs, Vector2 rhs);
    static inline Vector2 Lerp(Vector2 a, Vector2 b, float t);
    static inline Vector2 LerpUnclamped(Vector2 a, Vector2 b, float t);
    static inline float Magnitude(Vector2 v);
    static inline Vector2 Max(Vector2 a, Vector2 b);
    static inline Vector2 Min(Vector2 a, Vector2 b);
    static inline Vector2 Normalized(Vector2 v);
    static inline Vector2 Project(Vector2 a, Vector2 b);
    static inline Vector2 Reject(Vector2 a, Vector2 b);
    static inline Vector2 Scale(Vector2 a, Vector2 b);
    static inline Vector2 SlerpUnclamped(Vector2 a, Vector2 b, float t);
    static inline float SqrMagnitude(Vector2 v);

    inline struct Vector2& operator+=(const float rhs);
    inline struct Vector2& operator-=(const float rhs);
    inline struct Vector2& operator*=(const float rhs);
    inline struct Vector2& operator/=(const float rhs);
    inline struct Vector2& operator+=(const Vector2 rhs);
    inline struct Vector2& operator-=(const Vector2 rhs);
};

inline Vector2 operator-(Vector2 rhs);
inline Vector2 operator+(Vector2 lhs, const float rhs);
inline Vector2 operator-(Vector2 lhs, const float rhs);
inline Vector2 operator*(Vector2 lhs, const float rhs);
inline Vector2 operator/(Vector2 lhs, const float rhs);
inline Vector2 operator+(const float lhs, Vector2 rhs);
inline Vector2 operator-(const float lhs, Vector2 rhs);
inline Vector2 operator*(const float lhs, Vector2 rhs);
inline Vector2 operator/(const float lhs, Vector2 rhs);
inline Vector2 operator+(Vector2 lhs, const Vector2 rhs);
inline Vector2 operator-(Vector2 lhs, const Vector2 rhs);
inline bool operator==(const Vector2 lhs, const Vector2 rhs);
inline bool operator!=(const Vector2 lhs, const Vector2 rhs);

Vector2::Vector2() : X(0.f), Y(0.f) {}
Vector2::Vector2(float data[]) : X(data ? data[0] : 0.f), Y(data ? data[1] : 0.f) {}
Vector2::Vector2(float value) : X(value), Y(value) {}
Vector2::Vector2(float x, float y) : X(x), Y(y) {}

Vector2 Vector2::Zero() { return Vector2(0.f, 0.f); }
Vector2 Vector2::Right() { return Vector2(1.f, 0.f); }
Vector2 Vector2::Left() { return Vector2(-1.f, 0.f); }
Vector2 Vector2::Up() { return Vector2(0.f, 1.f); }
Vector2 Vector2::Down() { return Vector2(0.f, -1.f); }

float Vector2::Angle(Vector2 a, Vector2 b)
{
    float denom = Magnitude(a) * Magnitude(b);
    if (denom <= 1e-6f) return 0.f;
    float v = Dot(a, b) / denom;
    v = std::fmax(v, -1.0f);
    v = std::fmin(v, 1.0f);
    return std::acos(v);
}

float Vector2::Component(Vector2 a, Vector2 b)
{
    float magB = Magnitude(b);
    if (magB <= 1e-6f) return 0.f;
    return Dot(a, b) / magB;
}

float Vector2::Distance(Vector2 a, Vector2 b)
{
    return Vector2::Magnitude(a - b);
}

float Vector2::Dot(Vector2 lhs, Vector2 rhs)
{
    return lhs.X * rhs.X + lhs.Y * rhs.Y;
}

Vector2 Vector2::Lerp(Vector2 a, Vector2 b, float t)
{
    if (t < 0.f) return a;
    if (t > 1.f) return b;
    return LerpUnclamped(a, b, t);
}

Vector2 Vector2::LerpUnclamped(Vector2 a, Vector2 b, float t)
{
    return (b - a) * t + a;
}

float Vector2::Magnitude(Vector2 v)
{
    return std::sqrt(SqrMagnitude(v));
}

Vector2 Vector2::Max(Vector2 a, Vector2 b)
{
    float x = a.X > b.X ? a.X : b.X;
    float y = a.Y > b.Y ? a.Y : b.Y;
    return Vector2(x, y);
}

Vector2 Vector2::Min(Vector2 a, Vector2 b)
{
    float x = a.X > b.X ? b.X : a.X;
    float y = a.Y > b.Y ? b.Y : a.Y;
    return Vector2(x, y);
}

Vector2 Vector2::Normalized(Vector2 v)
{
    float mag = Magnitude(v);
    if (mag <= 1e-6f)
        return Vector2::Zero();
    return v / mag;
}

Vector2 Vector2::Project(Vector2 a, Vector2 b)
{
    float m = Magnitude(b);
    if (m <= 1e-6f) return Vector2::Zero();
    return Dot(a, b) / (m * m) * b;
}

Vector2 Vector2::Reject(Vector2 a, Vector2 b)
{
    return a - Project(a, b);
}

Vector2 Vector2::Scale(Vector2 a, Vector2 b)
{
    return Vector2(a.X * b.X, a.Y * b.Y);
}

Vector2 Vector2::SlerpUnclamped(Vector2 a, Vector2 b, float t)
{
    float magA = Magnitude(a);
    float magB = Magnitude(b);
    if (magA <= 1e-6f || magB <= 1e-6f) {
        return LerpUnclamped(a, b, t);
    }
    Vector2 normA = a / magA;
    Vector2 normB = b / magB;
    float dot = Dot(normA, normB);
    dot = std::fmax(dot, -1.0f);
    dot = std::fmin(dot, 1.0f);
    float theta = std::acos(dot) * t;
    Vector2 relativeVec = Normalized(normB - normA * dot);
    Vector2 newVec = normA * std::cos(theta) + relativeVec * std::sin(theta);
    return newVec * (magA + (magB - magA) * t);
}

float Vector2::SqrMagnitude(Vector2 v)
{
    return v.X * v.X + v.Y * v.Y;
}

struct Vector2& Vector2::operator+=(const float rhs)
{
    X += rhs;
    Y += rhs;
    return *this;
}

struct Vector2& Vector2::operator-=(const float rhs)
{
    X -= rhs;
    Y -= rhs;
    return *this;
}

struct Vector2& Vector2::operator*=(const float rhs)
{
    X *= rhs;
    Y *= rhs;
    return *this;
}

struct Vector2& Vector2::operator/=(const float rhs)
{
    if (rhs != 0.f) {
        X /= rhs;
        Y /= rhs;
    }
    return *this;
}

struct Vector2& Vector2::operator+=(const Vector2 rhs)
{
    X += rhs.X;
    Y += rhs.Y;
    return *this;
}

struct Vector2& Vector2::operator-=(const Vector2 rhs)
{
    X -= rhs.X;
    Y -= rhs.Y;
    return *this;
}

Vector2 operator-(Vector2 rhs) { return rhs * -1.f; }
Vector2 operator+(Vector2 lhs, const float rhs) { return lhs += rhs; }
Vector2 operator-(Vector2 lhs, const float rhs) { return lhs -= rhs; }
Vector2 operator*(Vector2 lhs, const float rhs) { return lhs *= rhs; }
Vector2 operator/(Vector2 lhs, const float rhs) { return lhs /= rhs; }
Vector2 operator+(const float lhs, Vector2 rhs) { return rhs += lhs; }
Vector2 operator-(const float lhs, Vector2 rhs) { return rhs -= lhs; }
Vector2 operator*(const float lhs, Vector2 rhs) { return rhs *= lhs; }
Vector2 operator/(const float lhs, Vector2 rhs) {
    if (rhs.X != 0.f) rhs.X = lhs / rhs.X;
    if (rhs.Y != 0.f) rhs.Y = lhs / rhs.Y;
    return rhs;
}
Vector2 operator+(Vector2 lhs, const Vector2 rhs) { return lhs += rhs; }
Vector2 operator-(Vector2 lhs, const Vector2 rhs) { return lhs -= rhs; }

bool operator==(const Vector2 lhs, const Vector2 rhs)
{
    return lhs.X == rhs.X && lhs.Y == rhs.Y;
}

bool operator!=(const Vector2 lhs, const Vector2 rhs)
{
    return !(lhs == rhs);
}
