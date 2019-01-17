/*
%%%% Taak TAGP 2018-2019: Digital Twin %%%%

% Sven Baerten (1540637) - sven.baerten@student.uhasselt.be
% Faculteit Industriële Ingenieurswetenschappen - Master Elektronica-ICT aan de UHasselt en KU Leuven
% Vak: Toepassingen en algoritmes van geavanceerde programmeertalen [TAGP]
% Docenten: Paul Valckenaers en Kris Aerts

% Gepersonaliseerde opdracht: Digital Twin met Cowboy webserver (Cowboy: https://ninenines.eu/ en https://github.com/ninenines/cowboy)
*/


/* DIAGRAM */

// Send a GET request to the cowboy web server to retrieve the pipe application model in JSON
var pipe_system;

function getSystem(){
    return fetch('/requestPipeSystem')   // Fetch api explanation: https://scotch.io/tutorials/how-to-use-the-javascript-fetch-api-to-get-data
            .then((resp) => resp.json())
            .then(function(json) {
                pipe_system = json;        
                drawDiagram();    
                showResourceInformation(openedID);
            });
}
setInterval(function(){getSystem()},1000); // Request system from web server every second
getSystem();

// Draw the pipe application model diagram
var isDiagram = false; 
var myDiagram;

function drawDiagram() {     // Uses the gojs library, from https://gojs.net
    if(isDiagram == false){
        isDiagram = true;
        var $ = go.GraphObject.make;  

        // Create and setup the diagram container
        myDiagram = 
        $(go.Diagram, "myDiagramDiv",  // Create a Diagram in the DIV HTML element myDiagramDiv
            {
            initialContentAlignment: go.Spot.Center,
            initialAutoScale: go.Diagram.Uniform,
            allowCopy: false, allowDelete: false, allowInsert: false, allowRelink: false, 
            allowReshape: false, allowRotate: false, allowResize: false,
            layout: $(go.CircularLayout, {spacing: 50})
            }
        );
        
        // A symbol template for the resources e.g. pipe, pump ...
        var node_template_resource =
        $(go.Node, "Auto",
            { background: "white"}, { portId: "" }, 
            $(go.Shape,  
                { fill: "transparent", stroke: "black" }),
            $(go.Picture,
                { width: 64, height: 64, margin: 4}, new go.Binding("source", "src")),
            { click: function(e, obj) { showResourceInformation(obj.data.key); } }
        );  
            
        // Add resource template
        var templmap = new go.Map("string", go.Node);
        templmap.add("node_template_resource", node_template_resource);
        myDiagram.nodeTemplateMap = templmap;
        
        // Style connections between resources
        myDiagram.linkTemplate =
        $(go.Link,   
            $(go.Shape, { strokeWidth: 4, stroke: "rgb(0, 0, 0)" },
            new go.Binding("stroke", "pumpStatus", function(v) { return v == "on" ? "rgb(0, 0, 200)" : "rgb(0, 0, 0)"; }))
        );
        
        // Loop over each object
        var model_nodes = [];
        var model_links = [];

        var digitalTwin = pipe_system["Digital Twin"];
        var len = Object.keys(digitalTwin).length;
        var index;
        for(index = 0; index < len; index++){    
            var node, link;
            
            // Make the nodes (e.g. pipe)
            if(digitalTwin[index].resource_type == "PIPE") node = {"key": digitalTwin[index].ID, "category": "node_template_resource", "src": "/site/img/pipe.png"};
            else if(digitalTwin[index].resource_type == "PUMP") node = {"key": digitalTwin[index].ID, "category": "node_template_resource", "src": "/site/img/water_pump.png"};
            else if(digitalTwin[index].resource_type == "FLOW METER") node = {"key": digitalTwin[index].ID, "category": "node_template_resource", "src": "/site/img/flow_meter.png"};
            else if(digitalTwin[index].resource_type == "HEAT EXCHANGER") node = {"key": digitalTwin[index].ID, "category": "node_template_resource", "src": "/site/img/heat_exchanger.png"};
            model_nodes.push(node);   

            // Make the links
            if(index > 0){
                link = {"from": index, "to": index-1};
                model_links.push(link);
            }
            if(index == len-1){ // Last resource to first resource
                link = {"from": index, "to": 0};
                model_links.push(link);
            }
        }
        
        // Add the nodes and links to the model
        myDiagram.model = new go.GraphLinksModel(model_nodes, model_links); 
    }
}

// Connections in the diagram are blue when the pump is on and black when off
function connections_pumpStatus(Status) {
    var model = myDiagram.model;
    model.startTransaction("trans");
    var links = model.linkDataArray;
    links.forEach(element => { model.setDataProperty(element, "pumpStatus", Status); });    
    model.commitTransaction("trans");
}

// Function to show information about a resource
var openedID = -1;

function showResourceInformation(ID) {
    if (ID != -1) {
        openedID = ID;
        var container = document.getElementById("diagram-resource"); // Get element from HTML DOM
        
        while (container.firstChild) {
            container.removeChild(container.firstChild); // Clear contents of container
        }

        // Loop over pipe system json: "Digital Twin", "Real System" and "Mismatch"
        for(var name in pipe_system){
            if(name == "Digital Twin" || name == "Real System"){
                container.innerHTML += '<p style="font-size:24px; margin-top:10px; margin-bottom: 10px;">' + name + '</p>';
                
                var system = pipe_system[name];
                var resource_type = system[ID].resource_type;

                if (resource_type == "PIPE") {
                    container.innerHTML +=
                        '<p>ID: ' + ID + '</p>' +
                        '<p>resource_type: ' + resource_type + '</p>' +
                        '<p>resource_type_PID: ' + system[ID].resource_type_PID + '</p>' +
                        '<p>resource_PID: ' + system[ID].resource_PID + '</p>';
                } 
                else if (resource_type == "PUMP") {
                    container.innerHTML +=
                        '<p>ID: ' + ID + '</p>' +
                        '<p>resource_type: ' + resource_type + '</p>' +
                        '<p>resource_type_PID: ' + system[ID].resource_type_PID + '</p>' +
                        '<p>resource_PID: ' + system[ID].resource_PID + '</p>' +
                        '<p>status: ' + system[ID].status + '</p>';
                    
                    if(name == "Digital Twin"){
                        pump_button = 'style="margin-top:8px; padding:10px; border-radius: 8px; outline:none; font-weight: bold;';        
                        if(system[ID].status == 'on') pump_button += ' background-color:green;" ' + 'onClick="(function(){updatePump(\'off\',' + ID + ');})();"'; 
                        else pump_button += ' background-color:red;" ' + 'onClick="(function(){updatePump(\'on\',' + ID + ');})();"';
                        container.innerHTML += '<button type="button" ' + pump_button + '>Toggle Pump</button>';
                    }
                    if(name == "Real System") {
                        if(system[ID].status == 'on') connections_pumpStatus("on");
                        else connections_pumpStatus("off");
                    }
                }
                else if (resource_type == "FLOW METER") {
                    container.innerHTML +=
                        '<p>ID: ' + ID + '</p>' +
                        '<p>resource_type: ' + resource_type + '</p>' +
                        '<p>resource_type_PID: ' + system[ID].resource_type_PID + '</p>' +
                        '<p>resource_PID: ' + system[ID].resource_PID + '</p>' +
                        '<p>flow: ' + handleNegativeValue(system[ID].flow.toPrecision(4), ' l/min') + '</p>';
                        if(name == "Digital Twin") container.innerHTML += '<a href="http://localhost:8080/measurement_logging/Flow_Measurements.txt" target="_blank" style="color:blue;">Download measurements</a>';
                }
                else if (resource_type == "HEAT EXCHANGER") {
                    container.innerHTML +=
                        '<p>ID: ' + ID + '</p>' +
                        '<p>resource_type: ' + resource_type + '</p>' +
                        '<p>resource_type_PID: ' + system[ID].resource_type_PID + '</p>' +
                        '<p>resource_PID: ' + system[ID].resource_PID + '</p>' +
                        '<p>ingoing_temperature: ' + handleNegativeValue(system[ID].ingoing_temperature.toPrecision(4), ' °C') + '</p>' +
                        '<p>outgoing_temperature: ' + handleNegativeValue(system[ID].outgoing_temperature.toPrecision(4), ' °C') + '</p>';
                }
            } else if (name == "Mismatch"){
                container.innerHTML += '<p style="font-size:24px; margin-top:10px; margin-bottom: 10px;">' + name + '</p>';
                for(var x in pipe_system[name]){
                    var line = "";
                    var val = pipe_system[name][x];
                    if (val == true) line += '<p style="color:red;">';
                    else line += '<p>';
                    container.innerHTML += line + x + ': ' + val + '</p>'
                }
            }   
        }  
    }     
}

// A temperature and flow less than0 mean "off"
function handleNegativeValue(Value, Unit){
    if (Value < 0) {
        return "off";
    }
    return String(Value) + String(Unit);
}

// Function to toggle the pump
function updatePump(command, ID){
    if(command == 'on') enablePump().then(function(){ getSystem().then(function(){ showResourceInformation(ID); }); });
    else                disablePump().then(function(){ getSystem().then(function(){ showResourceInformation(ID); }); });    
}
// Send POST to Cowboy web server to turn the pump on
function enablePump(){
    return fetch("/enablePump", {method: "POST"});
}
// Send POST to Cowboy web server to turn the pump off
function disablePump(){
    return fetch("/disablePump", {method: "POST"}); 
}

// Get the temperature from Diepenbeek, with https://openweathermap.org/current
function getTemperature(){
    var Diepenbeek_ID = 2799413;
    return fetch("http://api.openweathermap.org/data/2.5/weather?id=" + String(Diepenbeek_ID) + "&units=metric&APPID=0272d1cbc3e2b3fb4d4130d07840a5f1") //APPID = user key (max 60 calls/minute to weather server)
            .then(function(response){
                return response.json()
                    .then(function(data){
                        return data.main.temp;
                    }
                )}
            );
}

// Send POST to Cowboy web server to set the ingoing temperature of the heat exchanger
var autoTemperature = true;
function setTemperature(){
    if(autoTemperature) getTemperature().then(function(temp){ return fetch("/setInTemperature/?temp=" + String(parseFloat(temp)+45.0), {method: "POST"} ); });     
}
setInterval(function(){setTemperature()},20000); // Update ingoing temperature of heat exchanger every 20 seconds
setTemperature();




/* TERMINAL */

// Terminal documentation: https://terminal.jcubic.pl/api_reference.php
var term = $('#terminal').terminal(function(command) {
        if (command == '') {
            this.echo('');
        } else{
            if(command == 'auto temperature on') autoTemperature = true; // For testing purposes
            else if(command == 'auto temperature off') autoTemperature = false;
            sendCommand(command);
        }
    }, {
        greetings: 'Terminal: "commands" for list of commands\n',
        name: 'CLI',
        prompt: 'root> ',
    });

// Send the terminal command to the Cowboy web server and print the response in the terminal
function sendCommand(command) {
    fetch("/terminalCommand", { // Send POST to Cowboy web server with terminal command
        method: "POST", 
        headers: {
            "Content-Type": "text/plain",
        },
        body: String(command)
    })
    .then(function(response) {
        if(response.ok) {
            return response.text()
                    .then(function(text) {
                        var x = '[[;green;]'.concat($.terminal.escape_brackets(text)).concat(']');
                        term.echo(x); // Print Cowboy web server response in terminal
                        return;
                    }); 
        }
        throw new Error('Not OK.');
    })
}