using System.Collections.Generic;

namespace grava.Models
{
    /// <summary>
    /// Replicated State Library Dictionary
    /// </summary>
    public class RslDictionary<TKey, TValue> : Dictionary<TKey, TValue>
    {
        public RslDictionary() : base() { }
        public RslDictionary(int capacity) : base(capacity) { }

        public TValue Set(TKey key, TValue value)
        {
            if (ContainsKey(key))
            {
                this[key] = value;
            }
            else
            {
                Add(key, value);
            }

            return value;
        }

        public TValue Get(TKey key)
        {
            if (ContainsKey(key))
            {
                return this[key];
            }

            return default;
        }

        public TValue Delete(TKey key)
        {
            TValue value = default;

            if (ContainsKey(key))
            {
                value = this[key];
            }

            Remove(key);

            return value;
        }
    }
}
