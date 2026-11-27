// HMOOD__TG@i_8_f

#pragma once

#define _USE_MATH_DEFINES
#include <cmath>

struct Vector3
{
    union
    {
        struct
        {
            float X;
            float Y;
            float Z;
        };
        float data[3];
    };

    inline Vector3();
    inline Vector3(float data[]);
    inline Vector3(float value);
    inline Vector3(float x, float y);
    inline Vector3(float x, float y, float z);

    static inline Vector3 Zero();
    static inline Vector3 Right();
    static inline Vector3 Left();
    static inline Vector3 Up();
    static inline Vector3 Down();
    static inline Vector3 Forward();

    static inline float Angle(Vector3 a, Vector3 b);
    static inline float Component(Vector3 a, Vector3 b);
    static inline Vector3 Cross(Vector3 lhs, Vector3 rhs);
    static inline float Distance(Vector3 a, Vector3 b);
    static inline float Dot(Vector3 lhs, Vector3 rhs);
    static inline Vector3 Lerp(Vector3 a, Vector3 b, float t);
    static inline Vector3 LerpUnclamped(Vector3 a, Vector3 b, float t);
    static inline float Magnitude(Vector3 v);
    static inline Vector3 Max(Vector3 a, Vector3 b);
    static inline Vector3 Min(Vector3 a, Vector3 b);
    static inline Vector3 Normalized(Vector3 v);
    static inline Vector3 Project(Vector3 a, Vector3 b);
    static inline Vector3 ProjectOnPlane(Vector3 vector, Vector3 planeNormal);
    static inline Vector3 Reject(Vector3 a, Vector3 b);
    static inline Vector3 Scale(Vector3 a, Vector3 b);
    static inline Vector3 SlerpUnclamped(Vector3 a, Vector3 b, float t);
    static inline float SqrMagnitude(Vector3 v);

    inline struct Vector3& operator+=(const float rhs);
    inline struct Vector3& operator-=(const float rhs);
    inline struct Vector3& operator*=(const float rhs);
    inline struct Vector3& operator/=(const float rhs);
    inline struct Vector3& operator+=(const Vector3 rhs);
    inline struct Vector3& operator-=(const Vector3 rhs);
};

inline Vector3 operator-(Vector3 rhs);
inline Vector3 operator+(Vector3 lhs, const float rhs);
inline Vector3 operator-(Vector3 lhs, const float rhs);
inline Vector3 operator*(Vector3 lhs, const float rhs);
inline Vector3 operator/(Vector3 lhs, const float rhs);
inline Vector3 operator+(const float lhs, Vector3 rhs);
inline Vector3 operator-(const float lhs, Vector3 rhs);
inline Vector3 operator*(const float lhs, Vector3 rhs);
inline Vector3 operator/(const float lhs, Vector3 rhs);
inline Vector3 operator+(Vector3 lhs, const Vector3 rhs);
inline Vector3 operator-(Vector3 lhs, const Vector3 rhs);
inline bool operator==(const Vector3 lhs, const Vector3 rhs);
inline bool operator!=(const Vector3 lhs, const Vector3 rhs);

Vector3::Vector3() : X(0.f), Y(0.f), Z(0.f) {}
Vector3::Vector3(float data[]) : X(data ? data[0] : 0.f), Y(data ? data[1] : 0.f), Z(data ? data[2] : 0.f) {}
Vector3::Vector3(float value) : X(value), Y(value), Z(value) {}
Vector3::Vector3(float x, float y) : X(x), Y(y), Z(0.f) {}
Vector3::Vector3(float x, float y, float z) : X(x), Y(y), Z(z) {}

Vector3 Vector3::Zero() { return Vector3(0.f, 0.f, 0.f); }
Vector3 Vector3::Right() { return Vector3(1.f, 0.f, 0.f); }
Vector3 Vector3::Left() { return Vector3(-1.f, 0.f, 0.f); }
Vector3 Vector3::Up() { return Vector3(0.f, 1.f, 0.f); }
Vector3 Vector3::Down() { return Vector3(0.f, -1.f, 0.f); }
Vector3 Vector3::Forward() { return Vector3(0.f, 0.f, 1.f); }

float Vector3::Angle(Vector3 a, Vector3 b)
{
    float denom = Magnitude(a) * Magnitude(b);
    if (denom <= 1e-6f) return 0.f;
    float v = Dot(a, b) / denom;
    v = std::fmax(v, -1.0f);
    v = std::fmin(v, 1.0f);
    return std::acos(v);
}

float Vector3::Component(Vector3 a, Vector3 b)
{
    float magB = Magnitude(b);
    if (magB <= 1e-6f) return 0.f;
    return Dot(a, b) / magB;
}

Vector3 Vector3::Cross(Vector3 lhs, Vector3 rhs)
{
    float x = lhs.Y * rhs.Z - lhs.Z * rhs.Y;
    float y = lhs.Z * rhs.X - lhs.X * rhs.Z;
    float z = lhs.X * rhs.Y - lhs.Y * rhs.X;
    return Vector3(x, y, z);
}

float Vector3::Distance(Vector3 a, Vector3 b)
{
    return Vector3::Magnitude(a - b);
}

float Vector3::Dot(Vector3 lhs, Vector3 rhs)
{
    return lhs.X * rhs.X + lhs.Y * rhs.Y + lhs.Z * rhs.Z;
}

Vector3 Vector3::Lerp(Vector3 a, Vector3 b, float t)
{
    if (t < 0.f) return a;
    if (t > 1.f) return b;
    return LerpUnclamped(a, b, t);
}

Vector3 Vector3::LerpUnclamped(Vector3 a, Vector3 b, float t)
{
    return (b - a) * t + a;
}

float Vector3::Magnitude(Vector3 v)
{
    return std::sqrt(SqrMagnitude(v));
}

Vector3 Vector3::Max(Vector3 a, Vector3 b)
{
    float x = a.X > b.X ? a.X : b.X;
    float y = a.Y > b.Y ? a.Y : b.Y;
    float z = a.Z > b.Z ? a.Z : b.Z;
    return Vector3(x, y, z);
}

Vector3 Vector3::Min(Vector3 a, Vector3 b)
{
    float x = a.X > b.X ? b.X : a.X;
    float y = a.Y > b.Y ? b.Y : a.Y;
    float z = a.Z > b.Z ? b.Z : a.Z;
    return Vector3(x, y, z);
}

Vector3 Vector3::Normalized(Vector3 v)
{
    float mag = Magnitude(v);
    if (mag <= 1e-6f)
        return Vector3::Zero();
    return v / mag;
}

Vector3 Vector3::Project(Vector3 a, Vector3 b)
{
    float m = Magnitude(b);
    if (m <= 1e-6f) return Vector3::Zero();
    return Dot(a, b) / (m * m) * b;
}

Vector3 Vector3::ProjectOnPlane(Vector3 vector, Vector3 planeNormal)
{
    return Reject(vector, planeNormal);
}

Vector3 Vector3::Reject(Vector3 a, Vector3 b)
{
    return a - Project(a, b);
}

Vector3 Vector3::Scale(Vector3 a, Vector3 b)
{
    return Vector3(a.X * b.X, a.Y * b.Y, a.Z * b.Z);
}

Vector3 Vector3::SlerpUnclamped(Vector3 a, Vector3 b, float t)
{
    float magA = Magnitude(a);
    float magB = Magnitude(b);
    if (magA <= 1e-6f || magB <= 1e-6f) {
        return LerpUnclamped(a, b, t);
    }
    Vector3 normA = a / magA;
    Vector3 normB = b / magB;
    float dot = Dot(normA, normB);
    dot = std::fmax(dot, -1.0f);
    dot = std::fmin(dot, 1.0f);
    float theta = std::acos(dot) * t;
    Vector3 relativeVec = Normalized(normB - normA * dot);
    Vector3 newVec = normA * std::cos(theta) + relativeVec * std::sin(theta);
    return newVec * (magA + (magB - magA) * t);
}

float Vector3::SqrMagnitude(Vector3 v)
{
    return v.X * v.X + v.Y * v.Y + v.Z * v.Z;
}

struct Vector3& Vector3::operator+=(const float rhs)
{
    X += rhs;
    Y += rhs;
    Z += rhs;
    return *this;
}

struct Vector3& Vector3::operator-=(const float rhs)
{
    X -= rhs;
    Y -= rhs;
    Z -= rhs;
    return *this;
}

struct Vector3& Vector3::operator*=(const float rhs)
{
    X *= rhs;
    Y *= rhs;
    Z *= rhs;
    return *this;
}

struct Vector3& Vector3::operator/=(const float rhs)
{
    if (rhs != 0.f) {
        X /= rhs;
        Y /= rhs;
        Z /= rhs;
    }
    return *this;
}

struct Vector3& Vector3::operator+=(const Vector3 rhs)
{
    X += rhs.X;
    Y += rhs.Y;
    Z += rhs.Z;
    return *this;
}

struct Vector3& Vector3::operator-=(const Vector3 rhs)
{
    X -= rhs.X;
    Y -= rhs.Y;
    Z -= rhs.Z;
    return *this;
}

Vector3 operator-(Vector3 rhs) { return rhs * -1.f; }
Vector3 operator+(Vector3 lhs, const float rhs) { return lhs += rhs; }
Vector3 operator-(Vector3 lhs, const float rhs) { return lhs -= rhs; }
Vector3 operator*(Vector3 lhs, const float rhs) { return lhs *= rhs; }
Vector3 operator/(Vector3 lhs, const float rhs) { return lhs /= rhs; }
Vector3 operator+(const float lhs, Vector3 rhs) { return rhs += lhs; }
Vector3 operator-(const float lhs, Vector3 rhs) { return rhs -= lhs; }
Vector3 operator*(const float lhs, Vector3 rhs) { return rhs *= lhs; }
Vector3 operator/(const float lhs, Vector3 rhs) {
    if (rhs.X != 0.f) rhs.X = lhs / rhs.X;
    if (rhs.Y != 0.f) rhs.Y = lhs / rhs.Y;
    if (rhs.Z != 0.f) rhs.Z = lhs / rhs.Z;
    return rhs;
}
Vector3 operator+(Vector3 lhs, const Vector3 rhs) { return lhs += rhs; }
Vector3 operator-(Vector3 lhs, const Vector3 rhs) { return lhs -= rhs; }

bool operator==(const Vector3 lhs, const Vector3 rhs)
{
    return lhs.X == rhs.X && lhs.Y == rhs.Y && lhs.Z == rhs.Z;
}

bool operator!=(const Vector3 lhs, const Vector3 rhs)
{
    return !(lhs == rhs);
}
