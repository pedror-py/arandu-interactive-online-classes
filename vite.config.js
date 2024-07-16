import imba from 'imba/plugin';
import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
	plugins: [imba()],
		server: {
			proxy: {
				'/api': {
					// target: 'http://34.95.157.7/mediasoup',
					target: 'http://localhost:8080/mediasoup',
					changeOrigin: true,
					rewrite: (path) => path.replace(/^\/api/, ''),
				},
				// '/mediasoup': {
				// 	target: 'http://localhost:8080/mediasoup',
				// 	ws: true,
				// 	changeOrigin: true,
				// 	rewrite: (path) => path.replace(/^\/api/, ''),
				// },
			},
	},
	resolve: {
		alias: {
			'@': path.resolve(__dirname, './src'),
		}
	}
});
