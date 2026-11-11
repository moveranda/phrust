// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'Phrust',
			description: 'An experimental game and physics engine written in Rust, rendered with WebGPU.',
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/moveranda/phrust' }],
			sidebar: [
				{
					label: 'Guides',
					items: [
						{ label: 'Getting started', slug: 'guides/getting-started' },
						{ label: 'Development workflow', slug: 'guides/development' },
					],
				},
				{
					label: 'Reference',
					items: [{ autogenerate: { directory: 'reference' } }],
				},
			],
		}),
	],
});
