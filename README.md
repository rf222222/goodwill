# Goodwill Protocol & Resource Allocation Protocol Smart Contracts
Goodwill Economy are driven by Goodwill Coins Smart Contracts that work together to push forward and realize a cause, idea or vision. While most activities are available via BEGINNING’s user friendly site, https://beginning.world, for users familiar with Ethereum Smart Contracts, direct interaction with Goodwill Coins Smart Contract API is also possible. 

BEGINNING also provides an optional white-label for Goodwill Coins ICO participants to re-brand the BEGINNING platform to use the Smart Contracts’ capabilities to service the population in its jurisdiction.

Petitions:  Crowd sourced enforcement of a goal, when local decision maker the petitioner's facing does not align with SDGs.

Pledges: Promise for collective action on a set goal by those who agree with the cause,
idea, or vision.

Donations: Giving as a way to support a cause, goal, or vision.

Partnerships & Communications: Messaging, Partnerships and Joint Partnerships to work on a cause, vision, or idea collectively.

Events:  Raises awareness of on-going causes, ideas, and visions. Events enable participants to jointly solve complex issues through crowd sourcing actionable solutions from invited audience. Event hosts are able to form public private partnerships in hosting the events.

Deals & Campaigns: Campaigns help user turn the causes, visions, and ideas into reality through crowd participation in the efforts

Offers:  This is a Smart Contract to receive an item promised for Goodwill Coin given, to facilitate B2B, B2C, and C2C Transactions. For example, a promise to ship an IoT equipment to another user for certain amount of Goodwill Coins, is a Smart Contract. We facilitate blockchain verification mechanism for the user to request product or service from a Deal Provider, for the Deal Provider to agree or disagree to provide the product or service for a given Goodwill coins, for the user to verify (or reject for refund) successful delivery of the product or service, and to conclude the Smart Contract with final blockchain recorded outcome.


Goodwill Coins:

	Fees Generated: 
		Small fee in Goodwill Coins is pooled for each transaction, which will be shared amongst Goodwill Economy participants according to Goodwill Coins ICO participation on an on-going basis.
	
	Goodwill Economy:
		Through initial Goodwill Coins ICO participants work to present their ideas, causes and visions to build the workings of Goodwill Economy using Goodwill Coins in a way that provides unlimited resource availability through efficient circulation of goods and materials produced by participants. 
    
    



# Resource Allocation Protocol APIs
 Resource Allocation Protocol supports different API commands for users, devices and resource operators.


* Resource User API

Resource User API can be called by any Ethereum account, including normal account and contract ones.

RequestUse(​Resource Reserve Network Addess X, Resource Type Y, Goodwill Coin Z)
	X:	Resource Reserve Network Address
	Y:	Resource Type Y
	Z:	Resource Token Z
	
	Requests usage of resource type Y for token Z, from Resource Contributor X

	For example, users can call RequestUse(0x, “Cloud Storage: 1 GB”, 100) to request usage of resource of type “Cloud Storage: 1GB” for 100 Goodwill Coins
	Successful request will result in usage instructions being returned

GetUsage(​Resource Reserve Network  X)
	X:	Resource Reserve Network Address
	
	Returns the available resource for use from resource address X, and other publically identifiable resource related data


* Resource Contributor API

Reserve Contributor APIs can be called by any account in the Ethereum network, though some API only works if the account already contributed.

There will be two different resource types in Resource Allocation Protocol:
	private ones which do not take public contributions
	public ones which allow others to contribute resources

The APIs for public resources:

ListResource(Resource Network Address X, Resource Type Y)
	X: Resource Network Address
	Y: Resource Type
	
	Introduces Resource in Network X of Type Y

ResourceAdd​ ​(Resource Contributor Address X, Resource Qty Y, Resource Type Z)
	X: Resource Contributor Address
	Y: Resource Quantity
	Z: Resource Type
	
	Add a new resource to the network. The resource is managed by the contributor

ResourceRemove​ ​(Resource Contributor Address X, Resource Qty Y, Resource Type Z)
	X: Resource Contributor Address
	Y: Resource Quantity
	Z: Resource Type
	
	Remove an existing resource from Resource Allocation Protocol.

Contribute(Resource Type X, Resource Quantity Y, Resource Description Z)
	X: Resource Type
	Y: Resource Quantity
	Z: Resource Description

	Allocate Resource of type X for Minimum Goodwill Coin Y, for Resource Quantity



* Resource Operator API

SetResourceTerm(​Resource Network X, Resource Type Y, Goodwill Coin Z)
	X: Resource Network
	Y: Resource Type
	Z: Goodwill Coin

	Update usage terms of Resource Network X, based on existing usage. (Goodwill Coin can be set higher when demand looks to be nearing total supply limit)



* Resource Network API

ListResourceNet(Resource Type X)
	X: Resource Type
	
	Returns Resource Networks for Resource Type X

CreateResourceNet​(Resource Network Name X, Resource Network Address Y, Resource Type Z)
	X: Resource Network Name
	Y: Resource Network Address
	Z: Resource Type
	
	Creates Resource Network for Resource Type Z in Resource Network Address Y

DelistResourceNet​(Resource Type X, Resource Contributor Address Y)
	X: Resource Type 		
	Y: Resource Contributor Address Y
	
	To stop accepting usage of resource Type X
