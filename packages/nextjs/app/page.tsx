// import Link from "next/link";
import SwapCard from "../components/swap/SwapCard";
import type { NextPage } from "next";

const Home: NextPage = () => {
  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <h1 className="text-center mb-8">
            {/* <span className="block text-2xl mb-2">Welcome to</span>
            <span className="block text-4xl font-bold">DEX V2</span> */}
          </h1>
          <SwapCard />
        </div>
      </div>
    </>
  );
};

export default Home;
