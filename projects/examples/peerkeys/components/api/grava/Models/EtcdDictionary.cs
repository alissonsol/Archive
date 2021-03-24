// Based on https://github.com/shubhamranjan/dotnet-etcd
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using dotnet_etcd;
using Etcdserverpb;

namespace grava.Models
{
    /// <summary>
    /// Etcd-based Dictionary
    /// </summary>
    public class EtcdDictionary<TKey, TValue> : Dictionary<TKey, TValue>
    {
        private EtcdClient _etcdClient;
        private Grpc.Core.Metadata _authToken;
        private string _prefix = "/grava/{0}";
        private int _prefixRemove = 7;

        private bool _isConnected;

        private bool EnsureConnected()
        {
            if (_isConnected)
            {
                return true;
            }

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

        public EtcdDictionary() : base() 
        {
            Console.WriteLine("-- EtcdDictionary()");

            EnsureConnected();
        }

        // Replace base methods
        new public bool ContainsKey(TKey key)
        {
            Console.Write("ContainsKey({0}): ", key.ToString());
            if (!EnsureConnected()) 
            {
                return false;
            }

            string _key = string.Format(_prefix, key.ToString());
            RangeResponse rangeResponse = _etcdClient.GetRange(_key, _authToken);
            Console.WriteLine(rangeResponse.Count);
            

            return (rangeResponse.Count > 0);
        }

        new public void Add(TKey key, TValue value)
        {
            Console.WriteLine("-- Add({0},{1})", key.ToString(), value.ToString());
            if (!EnsureConnected()) 
            {
                return;
            }

            string _key = string.Format(_prefix, key.ToString());
            string _value = value.ToString();

            _etcdClient.Put(_key, _value, _authToken);
        }

        new public bool Remove(TKey key)
        {
            Console.Write("Remove({0}): ", key.ToString());
            if (!EnsureConnected()) 
            {
                return false;
            }

            bool found = this.ContainsKey(key);
            string _key = string.Format(_prefix, key.ToString());
            _etcdClient.Delete(_key, _authToken);

            return found;
        }

        new public System.Collections.Generic.Dictionary<TKey, TValue>.KeyCollection Keys 
        {
            get 
            { 
                Dictionary<TKey, TValue> _returned = new Dictionary<TKey, TValue>();

                try
                {
                    if (!EnsureConnected()) 
                    {
                        return _returned.Keys;
                    }
                    string _key = string.Format(_prefix, "");
                    var kv = _etcdClient.GetRangeVal(_key, _authToken);
                    Console.WriteLine("-- Keys: {0}", kv.Count);

                    TValue _empty = GetValue<TValue>(string.Empty);
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

        new public TValue this[TKey key] 
        { 
            get
            {
                if (!EnsureConnected()) 
                {
                    return GetValue<TValue>(null);
                }
                string _key = string.Format(_prefix, key.ToString());
                string _value = _etcdClient.GetVal(_key, _authToken);
                Console.Out.WriteLine("-- [{0}] get = {1}", key.ToString(), _value);

                return GetValue<TValue>(_value);
            }
            set
            {
                Console.Out.WriteLine("-- [{0}] set = {1}", key.ToString(), value.ToString());
                this.Add(key, value);
            }
        }

        // Helper
        public static T GetValue<T>(String value)
        {
            return (T)Convert.ChangeType(value, typeof(T));
        }
    }
}
