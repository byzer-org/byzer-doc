# What is MLSQL Cluster? And it is said it will not be upgraded any more?
The function of MLSQL Cluster is actually quite misleading. MLSQL Cluster is actually a proxy that can manage multiple MLSQL Engine instances, and the typical application scenario is for load balancing. Of course MLSQL Cluster also offers some other load balancing strategies, such as forwarding the request to the most idle Engine instance, sending the requests to the instance with the most absolute resources remaining, or sending the requests to all engines. Meanwhile, MLSQL Cluster also supports read/write separating. 

Although with these powerful features, we are afraid that we have to temporarily stopped updating it due to the complexity of deployment. 

Now Console also supports in managing multiple Engines or selecting the required Engine. It can be used to fulfill most of the MLSQL Cluster features. 
