# Byzer-Lang command-line installation and configuration

Byzer supports running Byzer scripts with commandline tools, to provide users with more self-service automation capabilities. This article describes how to install and use this feature.

### Installation

#### 1. Set up Byzer-Lang environment

The following part will introduce the environment variables in Byzer-lang command line and how to install them.

1. Environment variables

First, you need to set two environment variables: `MLSQL_LANG_HOME` and `PATH`.

- **MLSQL_LANG_HOME**: The directory where the Byzer-lang command line is located. When setting `PATH`, you can use this variable to facilitate future settings.

- **PATH**: A list of paths to search for executable files. For example, if one executable file is to be executed, but the system could not locate the file in the current path, it will search all paths defined in `PATH` till the executable file is found.

   > The execution command (byzer) of the Byzer-Lang command line is located in the `bin` directory of the installation path, so this directory should also be added to the `PATH` variable.

2. Download the byzer-lang command line based on your operating system:

- [Mac](https://download.byzer.org/byzer/2.2.1/byzer-lang-darwin-amd64-3.0-2.2.1.tar.gz)
- [Linux](https://download.byzer.org/byzer/2.2.1/byzer-lang-linux-amd64-3.0-2.2.1.tar.gz)

3. Directory structure

This section takes the Mac environment as an example. After downloading the [compressed package for Mac environment](https://download.byzer.org/byzer/2.2.1/byzer-lang-darwin-amd64-3.0-2.2.1.tar.gz), unzip the tar package. The internal directory structure is as follows:

```
|-- bin
|-- jdk8
|-- libs
|-- logs
|-- main
|-- plugin
`-- spark
```

4. Introduce environment variables

Next, place the unzipped files in a fixed directory and configure environment variables, where `MLSQL_LANG_HOME` is the upper-level directory with the `bin` directory as its child directory, as shown below:

```
export MLSQL_LANG_HOME=/opt/byzer-lang-darwin-amd64-3.0-2.2.1
export PATH=${MLSQL_LANG_HOME}/bin:$PATH
```

> **Note**: The example package will be placed in the `/opt` directory, you can choose other directories. 

5. Check the version

After modifying the environment variables, you can use `version` to verify whether the installation succeeds and the version information. The specific commands are as follows:

```shell
byzer --version
```

If successfully configured, you will see the log as below:

```
mlsql lang cli version 0.0.4-dev (2021-09-29 51f8d6a)
```

#### 2. Execute Byzer-lang script

##### Example

Let's  see an example. Create a `hello.mlsql` script file with the following codes:

```
!hdfs -ls /tmp;
```

Execute the Byzer-Lang script with one command line:

```shell
byzer run ./hello.mlsql
```

Note: if you are a Mac user, you will be prompted about the security warning. To allow the app for running, click **System Preferences -> Security and Privacy -> Allow App Downloads from the Following Locations** and choose to still allow.


Then we can execute the script through the command line. The execution log is as follows:
```
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|fileSystem                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|Found 1 items
-rw-------   1 root wheel         36 2021-12-14 10:26 /tmp/fseventsd-uuid fseventsd-uuid
Found 1 items
-rwxrwxrwx   1 root wheel          0 2021-12-14 10:36 /tmp/com.symantec.avscandaemon.ME com.symantec.avscandaemon.ME
Found 1 items
-rw-------   1 root wheel          4 2021-12-14 10:26 /tmp/com.broadcom.mes.systemextension.launches com.broadcom.mes.systemextension.launches
Found 1 items
drwxr-xr-x   - jiachuan.zhu wheel        128 2021-12-14 10:28 /tmp/com.google.Keystone com.google.Keystone
Found 1 items
drwxr-xr-x   - root         wheel         64 2021-12-14 10:26 /tmp/powerlog powerlog
Found 1 items
drwx------   - jiachuan.zhu wheel         96 2021-12-14 10:27 /tmp/com.apple.launchd.H49bLnfY3x com.apple.launchd.H49bLnfY3x
Found 1 items
drwx------   - root         wheel        160 2021-12-16 10:30 /tmp/AVScanFrCP AVScanFrCP
Found 1 items
-rwxrwxrwx   1 root         wheel          0 2021-12-14 10:26 /tmp/SymUIAgents.MES SymUIAgents.MES
Found 1 items
-rw-------   1 root         wheel          4 2021-12-14 10:26 /tmp/com.symantec.daemon.launches com.symantec.daemon.launches
Found 1 items
-rwxr-xr-x   1 jiachuan.zhu wheel          0 2021-12-15 18:04 /tmp/thorrustsdk_702 thorrustsdk_702
Found 1 items
-rw-rw-rw-   1 root         wheel          0 2021-12-14 10:26 /tmp/registry.lock registry.lock
Found 1 items
-rwxrwxrwx   1 root         wheel          0 2021-12-14 10:26 /tmp/SymMCLMMES SymMCLMMES
|
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

> Now you have completed the installation and can begin to use Byzer command line.