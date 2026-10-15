/**
 * Copyright © 2023 Kamigayatsuri
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”),
 * to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * 我は汝に興味なく、汝も我に興味なし。我と汝の心懐を交わすに能わず。沈黙こそが価値。忘れ去らん。
 */
import fs from 'fs'; // file system, from Node.js
import path from 'path'; // path resolver from Node.js
import { fileURLToPath } from 'url'; // url resolver from Node.js

/**
 * transfer
 */
import CopyPlugin from 'copy-webpack-plugin'; // to copy files

/**
 * extractor
 */
import MiniCssExtractPlugin from 'mini-css-extract-plugin'; // extract CSS into separate files

/**
 * minimizer
 */
import HtmlMinimizerPlugin from 'html-minimizer-webpack-plugin'; // minimizer for html
import CssMinimizerPlugin from 'css-minimizer-webpack-plugin'; // minimizer for css
import TerserPlugin from 'terser-webpack-plugin'; // minimizer for js

export default (env, argv) => {
    const isProduction = argv.mode === 'production';

    // getting exec path
    const __filename = fileURLToPath(import.meta.url);
    const __dirname = path.dirname(__filename);

    /**
     * 出力ルートディレクトリ
     * @type {string}
     */
    const pathOutput = path.resolve(__dirname, 'public');

    const entry = {
        // 入力ファイルのパスを指定
        app: [
            './resources/js/app.js',
            './resources/scss/app.scss',
        ],
    };

    const hiddenMessage = fs.readFileSync(
        path.resolve(__dirname, 'resources/hidden.txt'),
        'utf8'
    );
    const hiddenMessagePattern = new RegExp(
        hiddenMessage.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    );

    const dateCurrent = new Date();

    /**
     * 2004年05月01日からの経過年月で自動付与のバージョンナンバーを作る
     */
    const months = (dateCurrent.getFullYear() - 2004) * 12 + dateCurrent.getMonth() - 4;
    const buildVersion = `${String(Math.floor(months / 12)).padStart(2, '0')}.${String(months % 12).padStart(2, '0')}.${String(dateCurrent.getDate()).padStart(2, '0')}`;
    const ogUpdateTime = dateCurrent.toISOString().replace(/\.\d{3}Z$/, 'Z');

    return {
        entry: entry,
        output: {
            filename: 'js/[name].js',  // 出力ファイル名
            path: pathOutput,

            // delete all files that managed by webpack.js
            clean: {
                keep: /^(?:img)(?:\/|$)|^favicon\.ico$/,
            },

            library: {
                type: 'module',  // ES Module として出力, 指定なしだとimportできないblobになる
            },
        },
        target: 'es2022',
        experiments: {
            outputModule: true, // Webpack 5 では必須
        },
        module: {
            rules: [
                {
                    test: /\.html$/i,
                },

                // CSS制御
                {
                    include: [
                        path.resolve(__dirname, 'resources/scss'),  // 対象ディレクトリ
                        path.resolve(__dirname, 'resources/fontawesome-free-7.3.1-web/scss'),  // 対象ディレクトリ
                    ],
                    test: /\.(sa|sc|c)ss$/i,

                    // 使用するローダー, 下から順に適用される
                    use: [
                        {
                            // CSSを別ファイルとして抽出
                            loader: MiniCssExtractPlugin.loader,
                            // options: { publicPath: '/public/css/' }
                        },
                        {
                            loader: 'css-loader',
                            options: {
                                url: false, // URLの解決を無効にする
                            },
                        },
                        {
                            // SCSSをCSSに変換
                            loader: 'sass-loader',
                            options: {
                                api: 'modern',
                                // sassOptions: {
                                //     quietDeps: true,
                                // },
                            },
                        }
                    ],
                },
                {
                    test: /\.css$/i,
                    use: [
                        MiniCssExtractPlugin.loader,
                        { loader: 'css-loader', options: { url: false } }
                    ],
                },
            ],
        },
        plugins: [
            new CopyPlugin({
                patterns: [
                    {
                        context: path.resolve(__dirname, 'resources/html'),
                        from: '**/*.html',
                        to: '[path][name].aspx',
                        // replace version of loading js, css, and img、og-update-time
                        transform(content) {
                            // contentにファイル全体が入るので、置換処理をかける
                            return content
                                .toString()
                                .replaceAll(
                                    '__BUILD_VERSION__',
                                    `${buildVersion}`
                                )
                                .replace(
                                    '__OG_UPDATE_TIME__',
                                    `${ogUpdateTime}`
                                )
                                .replace(
                                    /<head\b[^>]*>/i, `$&\n<!--\n${hiddenMessage}\n-->`);
                        },
                    },
                    {
                        from: path.resolve(__dirname, 'resources/.htaccess.tpl'),
                        to: '.htaccess',
                        toType: 'file',
                        // replace build time
                        transform(content) {
                            return content.toString().replaceAll(
                                '__BUILD_TIME__',
                                dateCurrent.toUTCString()
                            );
                        },
                    },
                    {
                        from: path.resolve(__dirname, 'resources/fontawesome-free-7.3.1-web/webfonts'),
                        to: 'webfonts',
                    }
                ],
            }),
            new MiniCssExtractPlugin({
                // path and filename for output css
                filename: (pathData) => {
                    if (pathData.chunk && pathData.chunk.name === 'app') {
                        return 'css/app.css';
                    }
                },
            }),
        ],
        optimization: {
            // minimize them if it's production environment
            minimize: isProduction,
            minimizer: [
                // js用ミニマイズ設定
                new TerserPlugin({
                    terserOptions: {
                        compress: {
                            defaults: true,
                            // remove console.log() and console.debug()
                            drop_console: true
                        },
                        format: {
                            comments: false,
                        },
                        keep_classnames: true, // to keep className
                        keep_fnames: true,     // to keep funcName
                        mangle: {
                            properties: {
                                // to short properties has prefix of `_`
                                regex: /^_/,
                            },

                        },
                    },
                    extractComments: false,
                    parallel: true,
                }),
                new HtmlMinimizerPlugin({
                    parallel: true,
                    minimizerOptions: {
                        collapseWhitespace: true,
                        // hiddenMessageがminifyで言えないように除外
                        ignoreCustomComments: [hiddenMessagePattern],
                    },
                    /**
                     * copy後に検証されるので、リソースのhtmlだけでなく、aspxも指定しておくことが必要なので要注意
                     */
                    test: /\.(htm|html|aspx|tpl)$/i, // target extension(suffix
                }),
                new CssMinimizerPlugin({ // activate css minimizer
                    parallel: true,
                }),
                `...`,  // for keeping JS minimizer
            ],
        },
        // order about prod or dev
        devtool: isProduction ? false : 'eval-source-map',

        // webpack の production モードでの最適化をさせないため none
        mode: isProduction ? 'none' : 'development',
    };
};