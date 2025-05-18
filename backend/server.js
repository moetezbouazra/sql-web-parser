const express = require('express');
const cors = require('cors');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Compile lexer and parser (do this once at startup)
function compileParser() {
    return new Promise((resolve, reject) => {
        // Compile lexer and parser
        exec('flex -o lex.yy.c sql-lexer.l && bison -d sql-parseur.y && gcc -o sql-parser lex.yy.c sql-parseur.tab.c', 
            { cwd: path.join(__dirname) }, 
            (error, stdout, stderr) => {
                if (error) {
                    console.error('Parse error:', stderr);
                    reject(new Error('Parser failed'));
                } else {
                    console.log('Parserd successfully');
                    resolve();
                }
            });
    });
}

// Execute SQL query using the compiled parser
function executeQuery(query) {
    return new Promise((resolve, reject) => {
        // Create a temporary file with the query
        const tempFile = path.join(__dirname, 'temp-query.sql');
        fs.writeFileSync(tempFile, query + ';', 'utf8');
        
        // Execute the parser with the query file
        exec(`./sql-parser ${tempFile}`, 
            { cwd: __dirname }, 
            (error, stdout, stderr) => {
                // Clean up the temporary file
                fs.unlink(tempFile, () => {});
                
                if (error) {
                    console.error('Execution error:', stderr);
                    reject(new Error(stderr || 'Query execution failed'));
                } else {
                    // Parse the output (you may need to adjust this based on your parser's output)
                    const result = {
                        message: stdout.trim() || 'Requette juste',
                    };
                    resolve(result);
                }
            });
    });
}

// API Endpoints
app.post('/executer-requete', async (req, res) => {
    try {
        const { requeteSql } = req.body;
        if (!requeteSql) {
            return res.status(400).json({ error: 'No SQL query provided' });
        }

        const result = await executeQuery(requeteSql);
        res.json({ resultat: result });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/tables', (req, res) => {
    // Mock data - in a real app you'd query your database
    res.json({
        tables: [
            { nom: 'utilisateurs' },
            { nom: 'commandes' },
            { nom: 'produits' },
            { nom: 'categories' }
        ]
    });
});

app.get('/historique', (req, res) => {
    // Mock data - in a real app you'd store/retrieve from a database
    res.json({ historique: [] });
});

// Initialize and start server
async function startServer() {
    try {
        await compileParser();
        
        app.listen(PORT, () => {
            console.log(`Server running on http://localhost:${PORT}`);
        });
    } catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
}

startServer();