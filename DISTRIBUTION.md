# 配布方法ガイド

このプロジェクトを他の人に配布する方法をまとめました。

## 推奨配布方法

### 1. GitHub リポジトリとして公開（最も推奨）

**メリット:**

- バージョン管理ができる
- イシューやプルリクエストでフィードバックを受けられる
- 更新を簡単に配布できる
- 他の開発者が貢献しやすい

**手順:**

1. GitHub で新しいリポジトリを作成

   ```bash
   # ローカルでGitリポジトリを初期化（まだの場合）
   git init
   git add .
   git commit -m "Initial commit"

   # GitHubでリポジトリを作成後、リモートを追加
   git remote add origin https://github.com/YOUR_USERNAME/awi.git
   git branch -M main
   git push -u origin main
   ```

2. README.md を更新して、インストール方法を記載

   - 既に`INSTALL.md`に記載済み

3. LICENSE ファイルを追加（推奨）

   - MIT License や Apache License 2.0 など

4. `.gitignore`ファイルを作成（必要に応じて）
   ```gitignore
   # macOS
   .DS_Store
   *.log
   ```

### 2. ZIP ファイルとして配布

**メリット:**

- GitHub アカウントがなくても配布できる
- シンプルで分かりやすい

**手順:**

1. プロジェクトを ZIP ファイルに圧縮
2. ファイル共有サービス（Google Drive、Dropbox など）にアップロード
3. ダウンロードリンクを共有

**注意点:**

- 更新を配布する際は、バージョン番号をファイル名に含める（例: `awi-v1.0.0.zip`）

### 3. Homebrew Formula として配布（上級者向け）

**メリット:**

- macOS ユーザーにとって最も簡単なインストール方法
- `brew install`で一発インストール

**手順:**

1. Homebrew Tap リポジトリを作成
2. Formula ファイルを作成
3. リポジトリを公開

詳細は [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook) を参照

## 配布前に確認すべきこと

### ✅ チェックリスト

- [ ] ハードコードされたパスがすべて修正されている
- [ ] README.md が最新の状態になっている
- [ ] インストール手順が明確に記載されている
- [ ] LICENSE ファイルが追加されている
- [ ] `.gitignore`が適切に設定されている（GitHub 配布の場合）
- [ ] セットアップスクリプトが動作することを確認
- [ ] アンインストール手順が記載されている

### テスト手順

1. 新しい macOS 環境（または別のユーザーアカウント）でテスト
2. セットアップスクリプトを実行
3. `awi`コマンドが動作することを確認
4. 自動再接続が動作することを確認

## バージョン管理

配布する際は、バージョン番号を付けることを推奨：

- `v1.0.0` - 初回リリース
- `v1.0.1` - バグ修正
- `v1.1.0` - 新機能追加

GitHub では、リリースタグを作成：

```bash
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0
```

## 配布時の注意事項

1. **セキュリティ**: スクリプトは WiFi 設定を変更するため、ユーザーに信頼してもらえるよう、コードを公開することを推奨

2. **権限**: macOS の「完全なディスクアクセス」権限が必要な場合があることを README に記載

3. **互換性**: macOS のバージョン要件を明記（例: macOS 10.14 以降）

4. **サポート**: イシュートラッカーやメールアドレスでサポートを受けられるようにする

## 宣伝方法

- Twitter/X で紹介
- Reddit の r/macOS や r/apple サブレディットで紹介
- Product Hunt に投稿
- 個人ブログで紹介
