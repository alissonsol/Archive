using grava.Models;
using Microsoft.AspNetCore.Mvc;
using System.Text;

namespace grava.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class KeyValueController : ControllerBase
    {
        private static readonly RslDictionary<string, string> _dictionary = new RslDictionary<string, string>();

        // curl -X GET "http://<server>:<port>/api/KeyValue" -H  "accept: text/plain"
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

        // curl -X GET "http://<server>:<port>/api/KeyValue/[key]" -H  "accept: text/plain"
        [HttpGet("{key}")]
        public string Get(string key)
        {
            System.Console.WriteLine(string.Format("grava.Get[{0}]", key));

            return _dictionary.Get(key);
        }

        // curl -X PUT "http://<server>:<port>/api/KeyValue/[key]" -H  "accept: */*" -H  "Content-Type: text/plain" -d "[value]"
        [HttpPut("{key}")]
        [Consumes("text/plain")]
        public void Put(string key, [FromBody] string value)
        {
            System.Console.WriteLine(string.Format("grava.Put[{0}] = {1}", key, value));            

            _dictionary.Set(key, value);
        }

        // curl -X DELETE "http://<server>:<port>/api/KeyValue/[key]" -H  "accept: */*"
        [HttpDelete("{key}")]
        public string Delete(string key)
        {
            System.Console.WriteLine(string.Format("grava.PDeleteut[{0}]", key));            

            return _dictionary.Delete(key);
        }
    }
}
