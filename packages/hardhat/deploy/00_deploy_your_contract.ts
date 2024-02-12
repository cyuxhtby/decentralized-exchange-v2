import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

/**
 * Deploys the Factory contract and then uses it to create a LiquidityPair instance
 * with MockToken contracts as token0 and token1.
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployFactoryAndLiquidityPair: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;
  const { ethers } = hre;

  // Deploy MockToken contracts for token0 and token1
  const token0Deployment = await deploy("MockToken", {
    from: deployer,
    args: ["Token0", "TK0"],
    log: true,
    autoMine: true,
  });

  const token1Deployment = await deploy("MockToken", {
    from: deployer,
    args: ["Token1", "TK1"],
    log: true,
    autoMine: true,
  });

  // Deploy the Factory contract
  const factoryDeployment = await deploy("Factory", {
    from: deployer,
    log: true,
    autoMine: true,
  });

  // Convert deployer address string to a Signer object
  const deployerSigner = await ethers.getSigner(deployer);

  // Get the deployed Factory contract to interact with it using the deployer Signer
  const FactoryContract = await ethers.getContractAt("Factory", factoryDeployment.address, deployerSigner);

  // Use the Factory to create a LiquidityPair for token0 and token1
  const createPairTx = await FactoryContract.createPair(token0Deployment.address, token1Deployment.address);
  await createPairTx.wait(); // Wait for the transaction to be mined

  const pairAddress = await FactoryContract.getPair(token0Deployment.address, token1Deployment.address);
  console.log(`LiquidityPair address: ${pairAddress}`);

  // Optionally, interact with the LiquidityPair contract using the deployer Signer
  const LiquidityPair = await ethers.getContractAt("LiquidityPair", pairAddress, deployerSigner);
  console.log("Token 0 address from LiquidityPair:", await LiquidityPair.token0());
  console.log("Token 1 address from LiquidityPair:", await LiquidityPair.token1());
};

export default deployFactoryAndLiquidityPair;
deployFactoryAndLiquidityPair.tags = ["Factory", "LiquidityPair"];
