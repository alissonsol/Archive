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

        // Replace base methods
        new public bool ContainsKey(TKey key)
        {
            return base.ContainsKey(key);
        }

        new public void Add(TKey key, TValue value)
        {
            base.Add(key, value);
        }

        new public bool Remove(TKey key)
        {
            return base.Remove(key);
        }

        new public System.Collections.Generic.Dictionary<TKey, TValue>.KeyCollection Keys
        {
            get { return base.Keys; }
        }

        new public TValue this[TKey key]
        {
            get
            {
                return base[key];
            }
            set
            {
                base[key] = value;
            }
        }
    }
}
