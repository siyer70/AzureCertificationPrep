using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.Documents;
using Microsoft.Azure.Documents.Client;
using Newtonsoft.Json;

namespace CosmosDBExplore
{
    class Program
    {
        static void Main(string[] args)
        {
            string endpointurl = "https://az532cosmosdb.documents.azure.com:443/";
            string primarykey = "f4JLBbWZTt6UJwVcPhvxn0sAkTRH2lMTINMCanUbsy5UNKABkmWp5FDtg4LkJ84m2bL4CB8AkJUkIvhQOdOB7A==";
            DocumentClient client = new DocumentClient(new Uri(endpointurl), primarykey);
            createDatabase(client);
        }

        private async static void createDatabase(DocumentClient client)
        {
            string db = "orgdb";
            string collectionName = "empcoll";
            await client.CreateDatabaseAsync(new Database { Id = db });
            DocumentCollection collection = new DocumentCollection();
            collection.Id = collectionName;
            collection.PartitionKey.Paths.Add("/Designation");
            await client.CreateDocumentCollectionIfNotExistsAsync(UriFactory.CreateDatabaseUri(db), 
                            collection, new RequestOptions { OfferThroughput = 2500});
            await client.CreateDocumentAsync(UriFactory.CreateDocumentCollectionUri(db, collectionName),
                    new Employee
                    {
                        Id = "S0001",
                        Designation = "Manager",
                        Age = 36,
                        JoiningDate = DateTime.UtcNow
                    }
            );

            Document result = await client.ReadDocumentAsync(
                UriFactory.CreateDocumentUri(db, collectionName, "S0001"),
                new RequestOptions { PartitionKey = new PartitionKey("Manager") });

            Employee readEmployee = (Employee)(dynamic)result;
            Console.WriteLine(readEmployee.Age);
            Console.ReadKey();
        }
    }
}
