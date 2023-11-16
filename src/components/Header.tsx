"use client";

import Connect from "./Connect";

export default function Header() {
  return (
    <header className=" flex h-20 items-center justify-between px-10">
      <div className=" text-center text-4xl">Apocalypse</div>
      <Connect />
    </header>
  );
}
