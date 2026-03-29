import Link from 'next/link';

export default function HomePage() {
  return (
    <div className="flex flex-col justify-center text-center flex-1 px-6">
      <h1 className="text-3xl font-bold mb-4">Homelab Docs</h1>
      <p className="text-muted-foreground max-w-2xl mx-auto">
        Documentation for a personal GitOps-managed homelab built around k3s,
        FluxCD, and a mix of self-hosted apps.
      </p>
      <div className="mt-6">
        <Link href="/docs" className="font-medium underline">
          Open the docs
        </Link>
      </div>
    </div>
  );
}
