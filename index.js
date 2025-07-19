const fs = require("fs").promises;
const path = require("path");
const express = require("express");
const config = require("./config");
const { connect, writeSession, patch, parseDir } = require("./lib");
const { getandRequirePlugins } = require("./lib/database/plugins");

class BotSystem {
   constructor() {
      global.__basedir = __dirname;
      this.app = express();
      this.port = process.env.PORT || 7860; // Changed to 7860 to match Dockerfile
      this.app.use(express.json()); // Add JSON middleware
   }

   async initialize() {
      try {
         await patch();
         await writeSession();
         await parseDir(path.join(__dirname, "/lib/database/"));
         console.log("Syncing Database");
         await config.DATABASE.sync();
         await parseDir(path.join(__dirname, "/plugins/"));
         await getandRequirePlugins();
         console.log("External Modules Installed");
         return await connect();
      } catch (error) {
         console.error("Initialization error:", error);
         process.exit(1); // Exit on critical error
      }
   }

   async startServer() {
      this.app.get("/", (req, res) => {
         res.status(200).json({ status: "running" }); // Better response
      });

      this.app.listen(this.port, '0.0.0.0', () => { // Added '0.0.0.0' for Docker
         console.log(`Server running on port ${this.port}`);
      });
   }

   async tempDir() {
      const dir = path.join(__dirname, "temp");
      try {
         await fs.access(dir);
      } catch (err) {
         if (err.code === "ENOENT") {
            await fs.mkdir(dir, { recursive: true });
         }
      }
   }

   async createGitignore() {
      const content = `node_modules
.gitignore
session
.env
package-lock.json
database.db`;

      try {
         await fs.writeFile(".gitignore", content);
         console.log(".gitignore created");
      } catch (err) {
         console.error("Error creating .gitignore:", err);
      }
   }

   async main() {
      try {
         await this.initialize();
         await this.startServer();
         await this.tempDir();
         await this.createGitignore();
      } catch (error) {
         console.error("Bot System Failed:", error);
         process.exit(1);
      }
   }
}

const botSystem = new BotSystem();
botSystem.main();

// Error handlers
process.on('unhandledRejection', (err) => {
   console.error('Unhandled Rejection:', err);
});

process.on('uncaughtException', (err) => {
   console.error('Uncaught Exception:', err);
});
