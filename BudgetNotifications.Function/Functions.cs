using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.SignalRService;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace BudgetNotifications.Function
{
    public static class Functions
    {
        // This will manage connections to SignalR
        [FunctionName("negotiate")]
        public static SignalRConnectionInfo GetSignalRInfo(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequest req,
            [SignalRConnectionInfo(HubName = "chatHub")] SignalRConnectionInfo connectionInfo)
        {
            return connectionInfo;
        }

        //Send the messages!
        [FunctionName("messages")]
        public static Task SendMessage(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post")] ClientMessage clientMessage,
            [SignalR(HubName = "chatHub")] IAsyncCollector<SignalRMessage> signalRMessages)
        {
            return signalRMessages.AddAsync(
                new SignalRMessage
                {
                    Target = "clientMessage",
                    Arguments = new[] { clientMessage }
                });
        }
    }

    public class ClientMessage
    {
        public string Name { get; set; }
        public string Message { get; set; }
    }
}