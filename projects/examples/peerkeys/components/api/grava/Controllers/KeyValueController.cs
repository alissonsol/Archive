using grava.Models;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Text;

namespace grava.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class KeyValueController : ControllerBase
    {
        // private static readonly Dictionary<string, string> _dictionary = new RslDictionary<string, string>();
        private static EtcdDictionary<string, string> _dictionary = new EtcdDictionary<string, string>();

        // curl -X GET "{backendUrl}" -H  "accept: text/plain"
        [HttpGet]
        public string Get()
        {
            System.Console.WriteLine(string.Format("grava.Get[]"));

            StringBuilder sb = new StringBuilder();
            foreach (string k in _dictionary.Keys)
            {
                sb.Append(string.Format("{0}\n", k));
            }

            return sb.ToString();
        }

        // curl -X GET "{backendUrl}/[key]" -H  "accept: text/plain"
        [HttpGet("{key}")]
        public string Get(string key)
        {
            System.Console.WriteLine(string.Format("grava.Get[{0}]", key));

            if (_dictionary.ContainsKey(key))
            {
                return _dictionary[key];
            }

            return string.Empty;
        }

        // curl -X PUT "{backendUrl}/[key]" -H  "accept: */*" -H  "Content-Type: text/plain" -d "[value]"
        [HttpPut("{key}")]
        [Consumes("text/plain")]
        public void Put(string key, [FromBody] string value)
        {
            System.Console.WriteLine(string.Format("grava.Put[{0}] = {1}", key, value));

            if (_dictionary.ContainsKey(key))
            {
                _dictionary[key] = value;
            }
            else
            {
                _dictionary.Add(key, value);
            }
        }

        // curl -X DELETE "{backendUrl}/[key]" -H  "accept: */*"
        [HttpDelete("{key}")]
        public string Delete(string key)
        {
            System.Console.WriteLine(string.Format("grava.Delete[{0}]", key));

            string value = string.Empty;
            if (_dictionary.ContainsKey(key))
            {
                value = _dictionary[key];
            }
            _dictionary.Remove(key);

            return value;
        }
    }
}
