using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace CosmosDBExplore
{
    public class Employee
    {
        [JsonProperty]
        public string Id;

        [JsonProperty]
        public string Name;

        [JsonProperty]
        public string Designation;

        [JsonProperty]
        public int Age;

        [JsonConverter(typeof(IsoDateTimeConverter))]
        [JsonProperty]
        public DateTime JoiningDate; 
    }
}
