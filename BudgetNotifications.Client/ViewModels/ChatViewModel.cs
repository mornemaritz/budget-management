using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.SignalR.Client;
/*

public class ChatViewModel: ComponentBase, IChatViewModel
{
    
    TBC

    private HubConnection hubConnection; //for connecting to SignalR
    private List<ClientMessage> messages = new List<ClientMessage>(); //List of messages to display
    private string userInput; //username
    private string messageInput; //message
    private readonly HttpClient _httpClient = new HttpClient(); //HttpClient for posting messages

    private readonly string functionAppBaseUri = "http://localhost:7071/api/"; //URL for function app. Leave this as is for now.

    protected override async Task OnInitializedAsync() //actions to do when the page is initialized
    {
        //create a hub connection to the function app as we'll go via the function for everything SignalR.
        hubConnection = new HubConnectionBuilder()
            .WithUrl(functionAppBaseUri)
            .Build();

        //Registers handler that will be invoked when the hub method with the specified method name is invoked.
        hubConnection.On<ClientMessage>("clientMessage", (clientMessage) =>
        {
            messages.Add(clientMessage);
            StateHasChanged(); //This tells Blazor that the UI needs to be updated
        });

        await hubConnection.StartAsync(); //start connection!
    }

    //send our message to the function app
    async Task SendAsync() {

        var msg = new ClientMessage
        {
            Name = userInput,
            Message = messageInput
        };

        await _httpClient.PostAsJsonAsync($"{functionAppBaseUri}messages", msg); // post to the function app
        messageInput = string.Empty; // clear the message from the textbox
        StateHasChanged(); //update the UI
    }

    //Check we're connected
    public bool IsConnected =>
        hubConnection.State == HubConnectionState.Connected;

    public class ClientMessage
    {
        public string Name { get; set; }
        public string Message { get; set; }
    }
}
*/