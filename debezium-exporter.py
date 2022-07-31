from flask import Flask
import http.client
import os
import json

app = Flask(__name__)

@app.route('/metrics')
def metrics():
    metrics = ""
    connection = http.client.HTTPConnection(os.environ['debezium'])
    connection.request("GET", "/connectors")
    response = connection.getresponse()
    connectors_list=json.loads(response.read().decode())
    print(connectors_list)

    for connector in connectors_list:
        connection.request("GET", "/connectors/"+connector+"/status")
        state = connection.getresponse().read().decode()
        state=json.loads(state)
        print("connector:"+state['connector']['state'])
        metrics+='connector_%s{state=%s}\n' % (connector,state['connector']['state'])
        for task in state['tasks']:
            metrics+='connector_%s_task_%s{state=%s}\n' % (connector,str(task['id']),task['state'])
            print("task : "+str(task['id'])+" "+task['state'])

    connection.close()
    
    return metrics
