import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployRouter: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const factoryDeployment = await hre.deployments.get("Factory");
  const factoryAddress = factoryDeployment.address;

  console.log(`Deployed Factory Address: ${factoryAddress}`);


  console.log("Attempting to deploy router...");

  try {
    const routerDeployment = await deploy("Router", {
      from: deployer,
      args: [factoryAddress],
      log: true,
      autoMine: true,
    });
    console.log(`Router deployed at: ${routerDeployment.address}`);
  } catch (error) {
    console.error("Failed to deploy Router:", error);
  }
};

export default deployRouter;
deployRouter.tags = ["Router"];
