"use client";

import React, { useState } from "react";

const SwapCard = () => {
  const [fromAmount, setFromAmount] = useState("");
  const [toAmount, setToAmount] = useState("");
  const [fromToken, setFromToken] = useState("ETH");
  const [toToken, setToToken] = useState("DAI");

  return (
    <div className="max-w-md mx-auto mt-24 bg-white shadow-lg rounded-lg p-5">
      <h2 className="text-xl font-semibold text-center mb-4 text-black">Swap</h2>
      <div className="mb-4">
        <label htmlFor="fromAmount" className="block text-sm font-medium text-gray-700">
          From
        </label>
        <div className="mt-1 relative rounded-md shadow-sm">
          <input
            type="text"
            name="fromAmount"
            id="fromAmount"
            value={fromAmount}
            onChange={(e: any) => setFromAmount(e.target.value)}
            className="focus:ring-indigo-500 focus:border-indigo-500 block w-full pl-3 pr-12 sm:text-sm border-gray-300 rounded-md"
            placeholder="0.0"
          />
          <div className="absolute inset-y-0 right-0 flex items-center">
            <label htmlFor="fromToken" className="sr-only">
              From Token
            </label>
            <select
              id="fromToken"
              name="fromToken"
              value={fromToken}
              onChange={(e: any) => setFromToken(e.target.value)}
              className="focus:ring-indigo-500 focus:border-indigo-500 h-full py-0 pl-2 pr-7 border-transparent bg-transparent text-gray-500 sm:text-sm rounded-md"
            >
              <option>ETH</option>
              <option>DAI</option>
            </select>
          </div>
        </div>
      </div>

      <div className="mb-4">
        <label htmlFor="toAmount" className="block text-sm font-medium text-gray-700">
          To
        </label>
        <div className="mt-1 relative rounded-md shadow-sm">
          <input
            type="text"
            name="toAmount"
            id="toAmount"
            value={toAmount}
            onChange={e => setToAmount(e.target.value)}
            className="focus:ring-indigo-500 focus:border-indigo-500 block w-full pl-3 pr-12 sm:text-sm border-gray-300 rounded-md"
            placeholder="0.0"
            disabled
          />
          <div className="absolute inset-y-0 right-0 flex items-center">
            <label htmlFor="toToken" className="sr-only">
              To Token
            </label>
            <select
              id="toToken"
              name="toToken"
              value={toToken}
              onChange={(e: any) => setToToken(e.target.value)}
              className="focus:ring-indigo-500 focus:border-indigo-500 h-full py-0 pl-2 pr-7 border-transparent bg-transparent text-gray-500 sm:text-sm rounded-md"
            >
              <option>DAI</option>
              <option>ETH</option>
            </select>
          </div>
        </div>
      </div>

      <div className="mt-8">
        <button
          type="submit"
          className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Swap
        </button>
      </div>
    </div>
  );
};

export default SwapCard;
