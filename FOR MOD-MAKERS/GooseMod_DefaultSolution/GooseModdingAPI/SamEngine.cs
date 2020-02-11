using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SamEngine;

namespace SamEngine
{
    public static class Time
    {
        public const int framerate = 120;

        // Do not edit
        public const float deltaTime = 1f / (float)framerate;
        public static System.Diagnostics.Stopwatch timeStopwatch;
        public static float time = 0;

        static Time()
        {
            timeStopwatch = new System.Diagnostics.Stopwatch();
            timeStopwatch.Start();
            TickTime();
        }

        public static void TickTime()
        {
            time = (float)timeStopwatch.Elapsed.TotalSeconds;
        }

    }

    public static class SamMath
    {
        public const float Deg2Rad = (float)Math.PI / 180f;
        public const float Rad2Deg = 180f / (float)Math.PI;

        public static Random Rand = new Random();
        public static float RandomRange(float min, float max)
        {
            return min + (float)SamMath.Rand.NextDouble() * (max - min);
        }

        public static float Lerp(float a, float b, float p)
        {
            return (a * (1f - p)) + (b * p);
        }

        public static float Clamp(float a, float min, float max)
        {
            return Math.Min(Math.Max(a, min), max);
        }
    }

    public class Deck
    {
        public int[] indices;/// <summary>
        /// Do not mess with this unless you have a very good reason
        /// </summary>
        int i;
        public Deck(int Length)
        {
            indices = new int[Length];
            Reshuffle();
        }

        public void Reshuffle()
        {
            for (int j = 0; j < indices.Length; j++)
            {
                indices[j] = j;
                int otherIndex = (int)SamMath.RandomRange(0, j);
                int temp = indices[j];
                indices[j] = indices[otherIndex];
                indices[otherIndex] = temp;
            }
        }

        public int Next()
        {
            int result = indices[i];
            i++;
            if(i >= indices.Length)
            {
                Reshuffle();
                i = 0;
            }
            return result;
        }
    }

    // Math
    public struct Vector2
    {
        public float x, y;

        public static readonly Vector2 zero = new Vector2(0, 0);

        public Vector2(float _x, float _y)
        {
            x = _x;
            y = _y;
        }

        public static Vector2 operator +(Vector2 a, Vector2 b)
        {
            return new Vector2(a.x + b.x, a.y + b.y);
        }

        public static Vector2 operator -(Vector2 a, Vector2 b)
        {
            return new Vector2(a.x - b.x, a.y - b.y);
        }
        public static Vector2 operator -(Vector2 a)
        {
            return a * -1;
        }
        public static Vector2 operator *(Vector2 a, Vector2 b)
        {
            return new Vector2(a.x * b.x, a.y * b.y);
        }

        public static Vector2 operator *(Vector2 a, float b)
        {
            return new Vector2(a.x * b, a.y * b);
        }
        public static Vector2 operator /(Vector2 a, float b)
        {
            return new Vector2(a.x / b, a.y / b);
        }

        // Functions
        public static Vector2 GetFromAngleDegrees(float angle)
        {
            return new Vector2((float)Math.Cos(angle * SamMath.Deg2Rad), (float)Math.Sin(angle * SamMath.Deg2Rad));
        }

        public static float Distance(Vector2 a, Vector2 b)
        {
            Vector2 vector = new Vector2(a.x - b.x, a.y - b.y);
            return (float)Math.Sqrt(vector.x * vector.x + vector.y * vector.y);
        }

        public static Vector2 Lerp(Vector2 a, Vector2 b, float p)
        {
            return new Vector2(SamMath.Lerp(a.x, b.x, p), SamMath.Lerp(a.y, b.y, p));
        }

        public static float Dot(Vector2 a, Vector2 b)
        {
            return a.x * b.x + a.y * b.y;
        }

        public static Vector2 Normalize(Vector2 a)
        {
            if(a.x == 0 && a.y == 0) { return Vector2.zero; }
            float distance = (float)Math.Sqrt(a.x * a.x + a.y * a.y);
            return new Vector2(a.x / distance, a.y / distance);
        }

        public static float Magnitude(Vector2 a)
        {
            return (float)Math.Sqrt(a.x * a.x + a.y * a.y);
        }

        public static Vector2 ClampMagnitude(Vector2 a, float l)
        {
            if (Vector2.Magnitude(a) > l) { a = Vector2.Normalize(a) * l; }
            return a;
        }

    }

    // Input
    // Gets updated in the main game loop every frame.
    public static class Input
    {
        public static int mouseX, mouseY;
        public static ButtonState leftMouseButton;
    }

    public struct ButtonState
    {
        public bool Held, Clicked, Released;
        public void Update(bool heldThisFrame)
        {
            Clicked = heldThisFrame && !Held;
            Released = !heldThisFrame && Held;
            Held = heldThisFrame;
        }
    }
}