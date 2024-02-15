import { getMetadata } from "~~/utils/scaffold-eth/getMetadata";

export const metadata = getMetadata({
  title: "Pools",
  description: "Add liquidity",
});

const PoolsLayout = ({ children }: { children: React.ReactNode }) => {
  return <>{children}</>;
};

export default PoolsLayout;
