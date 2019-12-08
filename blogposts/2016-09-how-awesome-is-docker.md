Fully configured Ubuntu server up and running in minutes? On Windows?
Impossible you say? It is not!

Start by installing [Docker](https://www.docker.com/). We will try to
run the following Python code in the Docker container.



```

    try:
        from slackclient import SlackClient
        #import os # we need this for the next line
        # print the environment variable we exported in Dockerfile
        print(os.environ.get('SOME_TOKEN'))
    except Exception as e:
        print("Error when importing 'SlackClient'")
        print(repr(e))
    else:
        print("Succes!!!'")    
    finally:
        pass

```


Copy this snippet to a file and name it *somecode.py*. Create a file
called *Dockerfile* and paste the following into it.


```

    FROM ubuntu:latest
    # update apt-get then install python3.5 and pip3
    RUN apt-get -y update && apt-get install -y python3.5 && apt-get install -y python3-pip
    # update pip3
    RUN pip3 install --upgrade pip
    # install python modulesslackclient
    RUN pip3 install slackclient==1.0.0
    # copy source files
    COPY somecode.py /src/somecode.py
    # export some tokens
    ENV SOME_TOKEN='this is a token'
    # run the bot
    CMD ["python3.5", "/src/somecode.py"]

```


Then run these few lines of PowerShell.



```

    cd $PSScriptRoot
    # build the image (based on 'Dockerfile' in this folder) - ignore the security warning
    docker build -t codebeaver/dockerisawesome --force-rm .
    # run a container using the image we just created, --rm means we remove the container after it exists
    docker run --rm codebeaver/dockerisawesome

```


It may take some time to download the Ubuntu base image (ca. 500mb).

I intentionally put in an error. We did not import the *os* library in
the Python code. Uncomment *import os* and run the PowerShell code
again. That was it. You can easily install additional Python libraries
by editing the Dockerfile.

You can run the container in Azure and there are various services for
running Docker containers for you.

```

```
