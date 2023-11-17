import {
  watch,
  HttpCachingChain,
  HttpChainClient,
  G2ChainedBeacon,
} from "drand-client";
import { useState, useEffect } from "react";
import { roundTime } from "./helper";

const chainHash =
  "8990e7a9aaed2ffed73dbd7092123d6f289930540d7651336225dc172e51b2ce"; // (hex encoded)
const publicKey =
  "868f005eb8e6e4ca0a47c8a77ceaa5309a47978a7c71bc5cce96366b5d7a569937c529eeda66c7293784a9402801af31"; // (hex encoded)

const options = {
  disableBeaconVerification: false, // `true` disables checking of signatures on beacons - faster but insecure!!!
  noCache: false, // `true` disables caching when retrieving beacons for some providers
  chainVerificationParams: { chainHash, publicKey }, // these are optional, but recommended! They are compared for parity against the `/info` output of a given node
};

export const drandChain = new HttpCachingChain("https://api.drand.sh", options);
export const drandClient = new HttpChainClient(drandChain, options);

export const useBeacon = () => {
  const [beacon, setBeacon] = useState<G2ChainedBeacon>();

  useEffect(() => {
    const abortController = new AbortController();
    (async () => {
      for await (const beacon of watch(drandClient, abortController)) {
        setBeacon(beacon as G2ChainedBeacon);
      }
    })();

    return () => {
      abortController.abort();
    };
  }, []);

  return beacon;
};

export const useCountdown = (beacon?: G2ChainedBeacon) => {
  const [countdown, setCountdown] = useState<number>(0);

  useEffect(() => {
    if (!beacon) return;
    const interval = setInterval(() => {
      const now = Math.floor(Date.now() / 1000);
      const round = beacon.round;
      const time = roundTime(round) + 30;
      const countdown = time - now;
      setCountdown(countdown);
    }, 1000);

    return () => {
      clearInterval(interval);
    };
  }, [beacon]);

  return countdown;
};
