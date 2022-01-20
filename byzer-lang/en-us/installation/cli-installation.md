# Byzer-lang command line installation and configuration

We provide the ability to execute scripts with the command line to Byzer-lang, which is convenient for users to make byzer-lang have more automation capabilities. This article describes how to install and use Byzer-lang command line.

### Installation process

#### 1. Set up Byzer-lang environment

The following will introduce the meaning and installation processes of the environment variables in the Byzer-lang command line.

1. Environment variables

First you need to set two environment variables:`MLSQL_LANG_HOME` and `PATH`.

- **MLSQL_LANG_HOME**: The directory where the Byzer-lang command line is located. When setting `PATH`, you can use this variable for convenience.

- **PATH**: A list of paths to search for executable files. When executing an executable file, if the file cannot be found in the current path, each path in `PATH` will be searched in turn until the executable file is found.

   > The execution command (byzer) of the Byzer-lang command line is located in the bin directory under the installation path, so this directory should also be added to the PATH variable.

2. Download the byzer-lang command line.

Download the byzer-lang command line package from the following address:

- [Mac](https://download.byzer.org/byzer/2.2.1/byzer-lang-darwin-amd64-3.0-2.2.1.tar.gz)
- [Linux](https://download.byzer.org/byzer/2.2.1/byzer-lang-linux-amd64-3.0-2.2.1.tar.gz)

3. Directory Structure

It takes the mac environment as an example. After downloading the [compressed package adapted to the mac environment](https://download.byzer.org/byzer/2.2.1/byzer-lang-darwin-amd64-3.0-2.2.1.tar.gz), decompress the tar package. The internal directory structure is as follows:

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

Next, you need to place the decompressed files in a fixed directory and configure environment variables, where `MLSQL_LANG_HOME` is the upper-level directory including the `bin` directory, as shown below:

```
export MLSQL_LANG_HOME=/opt/byzer-lang-darwin-amd64-3.0-2.2.1
export PATH=${MLSQL_LANG_HOME}/bin:$PATH
```

> **Note** : this example places the package in the /opt directory, and users can specify other convenient locations.

5. View the user manual

After modifying the environment variables, you can use `version` to verify whether the installation is successful and the current byzer command line version. The specific commands are as follows:

```shell
byzer --version
```

If you configure successfully, the following log will be displayed:

```
mlsql lang cli version 0.0.4-dev (2021-09-29 51f8d6a)
```

#### 2. Execute Byzer-lang script

##### Example

Let's take a look at a complete example. We create a `hello.mlsql` script file with the following content:

```
!hdfs -ls /tmp;
```

Execute the byzer-lang script with one line:

```shell
byzer run ./hello.mlsql
```

Note: if you are a Mac user, you will be reminded about the security of the app. You need to click System Preferences - Security and Privacy - Allow App Downloads from the Following Locations and choose to still allow.


Then we can execute the script through the command line and view the effect. The execution log is as follows:
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

> Now you have completed the installation and use of Byzer command line.