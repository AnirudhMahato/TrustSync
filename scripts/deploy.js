const hre = require("hardhat");

async function main() {
  console.log("Starting TrustSync deployment...");
  console.log("==========================================\n");

  // Get the deployer's account.
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  
  // Get account balance
  const balance = await deployer.getBalance();
  console.log("Account balance:", hre.ethers.utils.formatEther(balance), "ETH\n");

  // Get the contract factory
  const Project = await hre.ethers.getContractFactory("Project");
  
  console.log("Deploying TrustSync contract...");
  
  // Deploy the contract
  const project = await Project.deploy();
  
  // Wait for deployment to complete
  await project.deployed();
  
  console.log("\n==========================================");
  console.log("✅ TrustSync contract deployed successfully!");
  console.log("==========================================\n");
  console.log("Contract Address:", project.address);
  console.log("Transaction Hash:", project.deployTransaction.hash);
  console.log("Block Number:", project.deployTransaction.blockNumber);
  console.log("Gas Used:", project.deployTransaction.gasLimit.toString());
  
  console.log("\n==========================================");
  console.log("Contract Details");
  console.log("==========================================\n");
  
  // Get initial contract state
  const agreementCounter = await project.agreementCounter();
  const reputationReward = await project.REPUTATION_REWARD();
  const reputationPenalty = await project.REPUTATION_PENALTY();
  
  console.log("Initial Agreement Counter:", agreementCounter.toString());
  console.log("Reputation Reward:", reputationReward.toString(), "points");
  console.log("Reputation Penalty:", reputationPenalty.toString(), "points");
  
  console.log("\n==========================================");
  console.log("Next Steps");
  console.log("==========================================\n");
  console.log("1. Verify your contract on Etherscan (if on mainnet/testnet):");
  console.log(`   npx hardhat verify --network <network> ${project.address}\n`);
  console.log("2. Save the contract address for frontend integration");
  console.log("3. Register users by calling registerUser()");
  console.log("4. Start creating agreements!\n");
  
  // Save deployment info to a file
  const fs = require('fs');
  const deploymentInfo = {
    contractAddress: project.address,
    transactionHash: project.deployTransaction.hash,
    blockNumber: project.deployTransaction.blockNumber,
    deployer: deployer.address,
    network: hre.network.name,
    timestamp: new Date().toISOString(),
    contractName: "TrustSync (Project.sol)"
  };
  
  fs.writeFileSync(
    'deployment-info.json',
    JSON.stringify(deploymentInfo, null, 2)
  );
  
  console.log("📄 Deployment info saved to deployment-info.json\n");
  console.log("==========================================");
  console.log("Deployment Complete! 🎉");
  console.log("==========================================\n");
}

// Execute deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n❌ Deployment failed!");
    console.error("==========================================\n");
    console.error(error);
    process.exit(1);

  });
