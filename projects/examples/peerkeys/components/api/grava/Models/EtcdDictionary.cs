// Based on https://github.com/shubhamranjan/dotnet-etcd
using Microsoft.Extensions.Configuration;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.Serialization;
using dotnet_etcd;
using Etcdserverpb;

namespace grava.Models
{
    /// <summary>
    /// Etcd-based Dictionary
    /// </summary>
    public class EtcdDictionary<TKey,TVal> : IDictionary<TKey,TVal>
    {
        private Dictionary<TKey, TVal> dictionary;
        private EtcdClient _etcdClient;
        private Grpc.Core.Metadata _authToken;
        private string _prefix = "/grava/{0}";
        private int _prefixRemove = 7;
        private bool _isConnected;

        public EtcdDictionary()
        {
            Console.WriteLine("-- EtcdDictionary()");

            EnsureConnected();

            dictionary = new Dictionary<TKey, TVal>();
        }

        public void CopyTo(Array array, int index)
        {
            ((ICollection) dictionary).CopyTo(array, index);
        }

        public object SyncRoot
        {
            get { return ((ICollection) dictionary).SyncRoot; }
        }

        public bool IsSynchronized
        {
            get { return ((ICollection) dictionary).IsSynchronized; }
        }

        public bool Contains(object key)
        {
            return ((IDictionary) dictionary).Contains(key);
        }

        public void Add(object key, object value)
        {
            ((IDictionary) dictionary).Add(key, value);
        }

        public void Remove(object key)
        {
            ((IDictionary) dictionary).Remove(key);
        }

        public object this[object key]
        {
            get { return dictionary[(TKey) key]; }
            set { dictionary[(TKey) key] = (TVal) value; }
        }

        public bool IsFixedSize
        {
            get { return ((IDictionary) dictionary).IsFixedSize; }
        }

        public void Add(TKey key, TVal value)
        {
            Console.WriteLine("-- EtcdDictionary.Add({0},{1})", key.ToString(), value.ToString());
            if (!EnsureConnected()) 
            {
                return;
            }

            string _key = string.Format(_prefix, key.ToString());
            string _value = value.ToString();

            _etcdClient.Put(_key, _value, _authToken);
        }

        public void Clear()
        {
            dictionary.Clear();
        }

        public bool Contains(KeyValuePair<TKey, TVal> item)
        {
            TVal v;
            return (dictionary.TryGetValue(item.Key, out v) && v.Equals(item.Key));
        }

        public void CopyTo(KeyValuePair<TKey, TVal>[] array, int arrayIndex)
        {
            ((ICollection<KeyValuePair<TKey, TVal>>)dictionary)
                .CopyTo(array,arrayIndex);
        }

        public bool Remove(KeyValuePair<TKey, TVal> item)
        {
            if (Contains(item))
            {
                dictionary.Remove(item.Key);
                return true;
            }
            return false;
        }

        public bool ContainsKey(TKey key)
        {
            Console.Write("-- EtcdDictionary.ContainsKey({0}): ", key.ToString());
            if (!EnsureConnected()) 
            {
                Console.WriteLine("false --");
                return false;
            }

            string _key = string.Format(_prefix, key.ToString());
            RangeResponse rangeResponse = _etcdClient.GetRange(_key, _authToken);
            Console.WriteLine(rangeResponse.Count);
            
            return (rangeResponse.Count > 0);
        }

        public bool ContainsValue(TVal value)
        {
            return dictionary.ContainsValue(value);
        }

        public void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            dictionary.GetObjectData(info, context);
        }

        public void OnDeserialization(object sender)
        {
            dictionary.OnDeserialization(sender);
        }

        public bool Remove(TKey key)
        {
            Console.Write("-- EtcdDictionary.Remove({0}): ", key.ToString());
            if (!EnsureConnected()) 
            {
                return false;
            }

            bool found = this.ContainsKey(key);
            string _key = string.Format(_prefix, key.ToString());
            _etcdClient.Delete(_key, _authToken);

            return found;
        }

        public bool TryGetValue(TKey key, out TVal value)
        {
            return dictionary.TryGetValue(key, out value);
        }

        public IEqualityComparer<TKey> Comparer
        {
            get { return dictionary.Comparer; }
        }

        public int Count
        {
            get { return dictionary.Count; }
        }

        public bool IsReadOnly { get; private set; }

        public TVal this[TKey key]
        {
            get
            {
                Console.Write("-- EtcdDictionary[{0}]", key.ToString());

                if (!EnsureConnected()) 
                {
                    return GetValue<TVal>(null);
                }
                
                string _key = string.Format(_prefix, key.ToString());
                string _value = _etcdClient.GetVal(_key, _authToken);
                Console.WriteLine(" get = {0}", _value);

                return GetValue<TVal>(_value);
            }
            set
            {
                Console.WriteLine("-- EtcdDictionary[{0}] = {1}", key.ToString(), value.ToString());
                
                this.Add(key, value);
            }
        }

        public ICollection<TKey> Keys
        {
            get 
            { 
                Dictionary<TKey, TVal> _returned = new Dictionary<TKey, TVal>();

                try
                {
                    if (!EnsureConnected()) 
                    {
                        return _returned.Keys;
                    }

                    string _key = string.Format(_prefix, "");
                    var kv = _etcdClient.GetRangeVal(_key, _authToken);
                    Console.WriteLine("-- Keys: {0}", kv.Count);

                    TVal _empty = GetValue<TVal>(string.Empty);
                    foreach (string k in kv.Keys)
                    {
                        string _k = k.Remove(0, _prefixRemove);
                        Console.Write("[{0}] ", _k);
                        _returned.Add( GetValue<TKey>(_k), _empty);
                    }
                    Console.WriteLine();
                }
                catch {}

                return _returned.Keys;
            }
        }

        public ICollection<TVal> Values
        {
            get { return dictionary.Values; }
        }

        public IEnumerator<KeyValuePair<TKey, TVal>> GetEnumerator()
        {
            return dictionary.GetEnumerator();
        }

        public void Add(KeyValuePair<TKey,TVal> item)
        {
            dictionary.Add(item.Key,item.Value);
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return dictionary.GetEnumerator();
        }        

        private bool EnsureConnected()
        {
            if (_isConnected)
            {
                return true;
            }

            Console.WriteLine("-- EtcdDictionary.EnsureConnected()");
            string etcdServer = Environment.GetEnvironmentVariable("etcdServer");
            if (string.IsNullOrEmpty(etcdServer))
            {
                etcdServer = new ConfigurationBuilder().AddJsonFile("appsettings.json").Build().GetSection("grava")["etcdServer"];
            }
            _etcdClient = new EtcdClient(etcdServer);

            string etcdPassword = Environment.GetEnvironmentVariable("etcdPassword");            
            if (string.IsNullOrEmpty(etcdPassword))
            {
                etcdPassword = new ConfigurationBuilder().AddJsonFile("appsettings.json").Build().GetSection("grava")["etcdPassword"];
            }

            try
            {
                _authToken = null;
                //var _authRes = _etcdClient.Authenticate(new AuthenticateRequest()
                //{
                //    Name = "root",
                //    Password = etcdPassword,
                //});
                //_authToken = new Grpc.Core.Metadata() { new Grpc.Core.Metadata.Entry("token", _authRes.Token) };          
                //Console.WriteLine("-- _authToken: {0}", _authToken[0]);
                StatusResponse status = _etcdClient.Status(new StatusRequest());
                if (!string.IsNullOrEmpty(status.Version))
                {
                    Console.WriteLine("-- Connection succeeded to {0}", etcdServer);
                    _isConnected = true;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("-- Connection failed to {0}\n{1}", etcdServer, ex.Message);
            }

            return _isConnected;
        }

        // Helper
        public static T GetValue<T>(String value)
        {
            return (T)Convert.ChangeType(value, typeof(T));
        }
    }
}
