# The SvelteKit Enterprise Stack Modifications

For our web2 portion, we started with the Sveltekit Enterprise Stack and upgraded dependent packages and adjusted the Stack to account for breaking changes in the dependencies.

## Our sveltekit bundle

Every part of the **Web3 SvelteKit Enterprise Bundle** is optimized for best developer experience and user experience:

- [Prisma](https://www.prisma.io/) for the database (v5.3)
- [Lucia](https://lucia-auth.com/) for authentication (v2.7)
- [Tailwind](https://tailwindcss.com/) for styling with automatic class sorting (v3.3) and [Skeleton UI](https://www.skeleton.dev/) for the UI components (v2.2)
- [Stripe](https://stripe.com/) for payments (v13.8)
- [sveltekit-superforms](https://github.com/ciscoheat/sveltekit-superforms) make working with forms easy (v1.8)
- [Lucide](https://lucide.dev/) for beautiful and consistent icons (v0.284)
- [TypeScript](https://www.typescriptlang.org/) (v5.2), [Prettier](https://prettier.io/), [ESLint](https://eslint.org/), [Playwright](https://playwright.dev/) and [Vitest](https://vitest.dev/) for testing configured

## Customization

Consult the respective documentation listed above to  **reconfigure** modules from database to authentication based on your needs. By default Prisma is configured with [SQLite](https://www.sqlite.org/index.html) but you could change it to **PostgreSQL**, **MySQL**, **MongoDB**, **CockroachDB** or **Microsoft SQL Server** or **Redis**. In most cases you don't need to change the Prisma schema. See [change the database connector](https://www.prisma.io/docs/concepts/database-connectors) for details.

## Database operations

Using `db push` is great for prototyping but you might want to use [Prisma migrate](https://www.prisma.io/docs/concepts/components/prisma-migrate) for production.

You can change the database schema inside `prisma/schema.prisma` and run `pnpx prisma studio` to look at your database.

## Payments

By default, Stripe payment is set up so that you could use it with minimal changes to the .env file but it can be easily disabled or removed without affecting the rest of the application.

- You need to create a Stripe account and place their
in the `.env` file
- You need to create products inside the [Stripe dashboard](https://dashboard.stripe.com/test/dashboard/products) and get the `productId`s
- You can [add a webhook endpoint](https://dashboard.stripe.com/test/webhooks) that points to `stripe/webhook` to respond to events like checkouts or if an invoice has been paid to continue or revoke access to your product

In order to work with [Stripe elements](https://stripe.com/payments/elements) you could use the [svelte-stripe](https://www.sveltestripe.com/) package that has a simple integration with instructions and examples.

### 💿️ Run the development server

```bash
pnpm run dev
```

## Blockchain integration

Solidity code that will be deployed on the blockchain should be under the packages/foundry/src directory. Also see packages/foundry/test. Typescript bindings that are needed for communications with a JSON-RPC provider from a client browser are in packages/foundry/out. See packages/sveltekit/src/routes/home.svelte for how to import and use these typescript bindings. If you have Metamask wallet installed as a browser extension, then the TypeScript/JavaScript code in home.svelte will use that. If you don't have a Metamask wallet then this code will use ethers.JsonRpcProvider to connect to the blockchain running on localhost (started by running pnpm anvil from the root of the project).

### ⛵️ Deploying

You can use any SvelteKit adapter that deploys to a target that supports a [Node.js](https://nodejs.org/) runtime.

Instead of a full-stack hosting solution you could provision a serverless PostgreSQL database provider using [Railway](https://railway.app/) or [Supabase](https://supabase.com/) and host your frontend on [Vercel](https://vercel.com/) starting at no cost.

You can use the forge create command to deploy your solidity code on a public blockchain (after extensive testing and security audits). Then you and your users should use Metamask wallet to handle the private key.

```bash
pnpm run build
```

You can also preview the build.

```bash
pnpm run preview
```
