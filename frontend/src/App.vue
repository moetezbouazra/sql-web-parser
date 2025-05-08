<template>
  <div id="application" class="dark-mode">
    <header class="en-tete">
      <div class="logo-container">
        <div class="logo">SQL</div>
        <div class="title-container">
          <h1>Compilateur SQL</h1>
          <p class="sous-titre">Interface d'analyse et d'exécution de requêtes SQL</p>
        </div>
      </div>
      <div class="theme-toggle">
        <button @click="toggleTheme" class="theme-button">
          <span v-if="darkMode">☀️ Mode clair</span>
          <span v-else>🌙 Mode sombre</span>
        </button>
      </div>
    </header>

    <div class="flex">
      <div class="panneau-lateral">

      <div class="historique">
        <h4>Historique des requêtes</h4>
        <button v-if="historique.length > 0" @click="viderHistorique" class="bouton-vider">
          Vider l'historique
        </button>
        <div class="historique-container">
          <div v-if="historique.length === 0" class="historique-vide">
            <p>Aucune requête dans l'historique</p>
          </div>
          <div v-else v-for="(item, index) in historique" :key="index" class="historique-item"
            @click="chargerRequeteHistorique(item.requete)">
            <div class="historique-time">
              {{ formatDate(item.timestamp || Date.now()) }}
            </div>
            <div class="historique-query">
              {{ tronquerTexte(item.requete, 40) }}
            </div>
          </div>
        </div>
      </div>

      <div class="shortcuts-help">
        <h4>Raccourcis clavier</h4>
        <div class="shortcut-list">
          <div class="shortcut-item">
            <span class="shortcut-key">F5</span>
            <span class="shortcut-desc">Exécuter la requête</span>
          </div>
          <div class="shortcut-item">
            <span class="shortcut-key">Ctrl+Space</span>
            <span class="shortcut-desc">Suggestions SQL</span>
          </div>
          <div class="shortcut-item">
            <span class="shortcut-key">Ctrl+F</span>
            <span class="shortcut-desc">Formater la requête</span>
          </div>
          <div class="shortcut-item">
            <span class="shortcut-key">Ctrl+T</span>
            <span class="shortcut-desc">Nouvel onglet</span>
          </div>
        </div>
      </div>
    </div>
      <div class="conteneur-principal">
      <div class="panneau-requete">
        <div class="editor-header">
          <h2>Éditeur de requête</h2>
          <div class="editor-tabs">
            <button v-for="(tab, index) in tabs" :key="index" @click="selectTab(index)"
              :class="['tab-button', { active: activeTabIndex === index }]">
              {{ tab.name }}
              <span v-if="index > 0" @click.stop="closeTab(index)" class="close-tab">×</span>
            </button>
            <button @click="addNewTab" class="add-tab">+</button>
          </div>
        </div>

        <div class="editor-container max-h-60">
          <textarea v-model="activeTab.content" class="zone-saisie" placeholder="Entrez votre requête SQL ici..."
            @keydown.tab="gererTabulation" ref="sqlEditor"></textarea>

          <div class="syntax-hints" v-if="syntaxHints.length > 0">
            <div v-for="(hint, index) in syntaxHints" :key="index" class="hint-item">
              {{ hint }}
            </div>
          </div>
        </div>

        <div class="controles">
          <button @click="executerRequete" class="bouton bouton-primaire">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="icon"
              viewBox="0 0 16 16">
              <path
                d="M11.596 8.697l-6.363 3.692c-.54.313-1.233-.066-1.233-.697V4.308c0-.63.692-1.01 1.233-.696l6.363 3.692a.802.802 0 0 1 0 1.393z" />
            </svg>
            Exécuter (F5)
          </button>
          <button @click="formaterRequete" class="bouton bouton-secondaire">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="icon"
              viewBox="0 0 16 16">
              <path d="M10.5 8a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0z" />
              <path d="M0 8s3-5.5 8-5.5S16 8 16 8s-3 5.5-8 5.5S0 8 0 8zm8 3.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z" />
            </svg>
            Formater
          </button>
          <button @click="effacerRequete" class="bouton bouton-danger">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="icon"
              viewBox="0 0 16 16">
              <path
                d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z" />
              <path fill-rule="evenodd"
                d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z" />
            </svg>
            Effacer
          </button>
          <div class="examples-dropdown">
            <button @click="toggleExamplesMenu" class="bouton bouton-info">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="icon"
                viewBox="0 0 16 16">
                <path
                  d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm.25-14.75v1.5a.75.75 0 0 1-1.5 0v-1.5a.75.75 0 0 1 1.5 0zm0 10.5v1.5a.75.75 0 0 1-1.5 0v-1.5a.75.75 0 0 1 1.5 0zM2 8a.75.75 0 0 1 .75-.75h1.5a.75.75 0 0 1 0 1.5h-1.5A.75.75 0 0 1 2 8zm10.5 0a.75.75 0 0 1 .75-.75h1.5a.75.75 0 0 1 0 1.5h-1.5a.75.75 0 0 1-.75-.75zM4.707 4.707a.75.75 0 0 1 0-1.06l1.06-1.06a.75.75 0 0 1 1.06 1.06l-1.06 1.06a.75.75 0 0 1-1.06 0zm6.586 6.586a.75.75 0 0 1 0-1.06l1.06-1.06a.75.75 0 0 1 1.06 1.06l-1.06 1.06a.75.75 0 0 1-1.06 0zM4.707 11.293a.75.75 0 0 1 0 1.06l-1.06 1.06a.75.75 0 0 1-1.06-1.06l1.06-1.06a.75.75 0 0 1 1.06 0zm6.586-6.586a.75.75 0 0 1 0 1.06l-1.06 1.06a.75.75 0 0 1-1.06-1.06l1.06-1.06a.75.75 0 0 1 1.06 0z" />
              </svg>
              Exemples
            </button>
            <div v-if="showExamplesMenu" class="examples-menu">
              <div v-for="(example, index) in exemples" :key="index" @click="insererExemple(example.query)"
                class="exemple-item">
                {{ example.title }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="panneau-resultats">
        <h2>Résultats</h2>

        <div v-if="chargement" class="indicateur-chargement">
          <div class="spinner"></div>
          <p>Exécution en cours...</p>
        </div>

        <div v-else-if="erreur" class="message-erreur">
          <div class="error-header">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" viewBox="0 0 16 16">
              <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z" />
              <path
                d="M7.002 11a1 1 0 1 1 2 0 1 1 0 0 1-2 0zM7.1 4.995a.905.905 0 1 1 1.8 0l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 4.995z" />
            </svg>
            <h3>Erreur détectée</h3>
          </div>
          <div class="error-content">
            <pre>{{ traduireErreur(erreur) }}</pre>
            <div v-if="suggestionsErreur.length > 0" class="error-suggestions">
              <h4>Suggestions :</h4>
              <ul>
                <li v-for="(suggestion, index) in suggestionsErreur" :key="index">
                  {{ suggestion }}
                </li>
              </ul>
            </div>
          </div>
        </div>

        <div v-else-if="resultat" class="contenu-resultat">
          <div class="resume-execution">
            <div class="success-header">
            </div>
            <div class="success-content text-gray-500">
              <p class="result-message">{{ traduireResultat(resultat.message) }}</p>
              <div class="success-stats">
                <div class="stat-item">
                  <span class="stat-label">Durée :</span>
                  <span class="stat-value">{{ tempsExecution }} ms</span>
                </div>
              </div>
            </div>
          </div>

          <div v-if="resultat.donnees" class="tableau-resultats">
            <table>
              <thead>
                <tr>
                  <th v-for="colonne in resultat.donnees.colonnes" :key="colonne">
                    {{ colonne }}
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(ligne, index) in resultat.donnees.donnees" :key="index">
                  <td v-for="colonne in resultat.donnees.colonnes" :key="colonne">
                    {{ ligne[colonne] }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="export-options" v-if="resultat.donnees">
            <button @click="exporterResultats('csv')" class="bouton bouton-export">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="icon"
                viewBox="0 0 16 16">
                <path
                  d="M.5 9.9a.5.5 0 0 1 .5.5v2.5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-2.5a.5.5 0 0 1 1 0v2.5a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-2.5a.5.5 0 0 1 .5-.5z" />
                <path
                  d="M7.646 11.854a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V1.5a.5.5 0 0 0-1 0v8.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3z" />
              </svg>
              Exporter CSV
            </button>
            <button @click="exporterResultats('json')" class="bouton bouton-export">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="icon"
                viewBox="0 0 16 16">
                <path
                  d="M9.828 4a3 3 0 0 1-2.12-.879l-.83-.828A1 1 0 0 0 6.173 2H2.5a1 1 0 0 0-1 .981L1.546 4h-1L.5 3a2 2 0 0 1 2-2h3.672a2 2 0 0 1 1.414.586l.828.828A2 2 0 0 0 9.828 3v1z" />
                <path fill-rule="evenodd"
                  d="M13.81 4H2.19a1 1 0 0 0-.996 1.09l.637 7a1 1 0 0 0 .995.91h10.348a1 1 0 0 0 .995-.91l.637-7A1 1 0 0 0 13.81 4zM2.19 3A2 2 0 0 0 .198 5.181l.637 7A2 2 0 0 0 2.826 14h10.348a2 2 0 0 0 1.991-1.819l.637-7A2 2 0 0 0 13.81 3H2.19z" />
              </svg>
              Exporter JSON
            </button>
          </div>
        </div>

        <div v-else class="message-vide">
          <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="currentColor" viewBox="0 0 16 16">
            <path
              d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z" />
            <path
              d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z" />
          </svg>
          <p class="message-vide-sub">Utilisez le panneau de gauche pour sélectionner une table ou choisissez un exemple
          </p>
        </div>
      </div>
    </div>
    </div>
<div class="absolute bottom-0 left-[50%]">
  <p>©Bouazra Moetez 2DNI2</p>

</div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick, watch } from 'vue';

// Reactive state
const darkMode = ref(true);
const requeteCourante = ref('');
const resultat = ref(null);
const erreur = ref(null);
const chargement = ref(false);
const tempsExecution = ref(0);
const syntaxHints = ref([]);
const showExamplesMenu = ref(false);
const suggestionsErreur = ref([]);

// Tabs system
const tabs = ref([
  { name: 'Requête 1', content: '' }
]);
const activeTabIndex = ref(0);

const activeTab = computed(() => {
  return tabs.value[activeTabIndex.value];
});

// Tables data
const tables = ref([
  { nom: 'utilisateurs' },
  { nom: 'commandes' },
  { nom: 'produits' },
  { nom: 'categories' }
]);

// History
const historique = ref([]);

// SQL examples
const exemples = [
  {
    title: 'SELECT simple',
    query: 'SELECT * FROM utilisateurs;'
  },
  {
    title: 'SELECT avec colonnes',
    query: 'SELECT nom, prenom, email FROM utilisateurs;'
  },
  {
    title: 'SELECT avec colonnes qualifiées',
    query: 'SELECT u.nom, u.prenom FROM utilisateurs u;'
  },
  {
    title: 'SELECT avec WHERE',
    query: 'SELECT * FROM produits WHERE prix > 100;'
  },
  {
    title: 'SELECT avec fonction d\'agrégation',
    query: 'SELECT AVG(prix) FROM produits;'
  },
  {
    title: 'SELECT avec GROUP BY',
    query: 'SELECT categorie, AVG(prix) FROM produits GROUP BY categorie;'
  },
  {
    title: 'SELECT avec HAVING',
    query: 'SELECT categorie, AVG(prix) FROM produits GROUP BY categorie HAVING AVG(prix) > 50;'
  },
  {
    title: 'SELECT avec ORDER BY',
    query: 'SELECT * FROM produits ORDER BY prix DESC;'
  },
  {
    title: 'SELECT avec JOIN',
    query: 'SELECT c.nom, p.nom FROM clients c INNER JOIN commandes p ON c.id = p.client_id;'
  },
  {
    title: 'SELECT avec LEFT JOIN',
    query: 'SELECT d.nom, e.nom FROM departements d LEFT JOIN employes e ON d.id = e.departement_id;'
  },
  {
    title: 'SELECT avec calcul',
    query: 'SELECT nom, prix * quantite AS total FROM produits;'
  },
  {
    title: 'INSERT simple',
    query: 'INSERT INTO produits VALUES (101, "Ordinateur", 999, 10);'
  },
  {
    title: 'INSERT avec colonnes',
    query: 'INSERT INTO produits (id, nom, prix, stock) VALUES (102, "Clavier", 49, 20);'
  },
  {
    title: 'DELETE tous',
    query: 'DELETE FROM produits;'
  },
  {
    title: 'DELETE avec WHERE',
    query: 'DELETE FROM produits WHERE stock = 0;'
  },
  {
    title: 'DROP table',
    query: 'DROP FROM produits;'
  },
  {
    title: 'SELECT avec conditions complexes',
    query: 'SELECT * FROM employes WHERE (salaire > 50000 AND departement = "IT") OR (anciennete > 5);'
  },
  {
    title: 'SELECT avec alias de table',
    query: 'SELECT e.nom, d.nom FROM employes AS e JOIN departements AS d ON e.departement_id = d.id;'
  },
  {
    title: 'SELECT avec fonctions multiples',
    query: 'SELECT MIN(prix), MAX(prix), AVG(prix) FROM produits;'
  },
  {
    title: 'SELECT avec jointure multiple',
    query: 'SELECT c.nom, p.nom, f.montant FROM clients c JOIN commandes p ON c.id = p.client_id JOIN factures f ON p.id = f.commande_id;'
  }
];

// Reference for SQL editor
const sqlEditor = ref(null);

// Watch for active tab change to update requeteCourante
watch(() => activeTab.value?.content, (newVal) => {
  requeteCourante.value = newVal;
}, { immediate: true });

// Watch for requeteCourante change to update active tab content
watch(requeteCourante, (newVal) => {
  if (activeTab.value) {
    activeTab.value.content = newVal;
  }
});

// Lifecycle hooks
onMounted(() => {
  chargerHistorique();
  chargerListeTables();

  // F5 shortcut for query execution
  window.addEventListener('keydown', (e) => {
    if (e.key === 'F5') {
      e.preventDefault();
      executerRequete();
    } else if (e.ctrlKey && e.key === 'f') {
      e.preventDefault();
      formaterRequete();
    } else if (e.ctrlKey && e.key === ' ') {
      e.preventDefault();
      afficherSuggestions();
    } else if (e.ctrlKey && e.key === 't') {
      e.preventDefault();
      addNewTab();
    }
  });

  // Check for saved theme preference
  const savedTheme = localStorage.getItem('sqlEditorTheme');
  if (savedTheme) {
    darkMode.value = savedTheme === 'dark';
  }

  // Apply theme class
  applyTheme();
});

// Theme methods
function toggleTheme() {
  darkMode.value = !darkMode.value;
  localStorage.setItem('sqlEditorTheme', darkMode.value ? 'dark' : 'light');
  applyTheme();
}

function applyTheme() {
  document.getElementById('application').className = darkMode.value ? 'dark-mode' : 'light-mode';
}

// Tab methods
function selectTab(index) {
  activeTabIndex.value = index;
}

function addNewTab() {
  const newTabNumber = tabs.value.length + 1;
  tabs.value.push({ name: `Requête ${newTabNumber}`, content: '' });
  activeTabIndex.value = tabs.value.length - 1;
  nextTick(() => {
    if (sqlEditor.value) {
      sqlEditor.value.focus();
    }
  });
}

function closeTab(index) {
  if (tabs.value.length <= 1) return; // Always keep at least one tab

  // Remove the tab
  tabs.value.splice(index, 1);

  // Adjust active tab index if needed
  if (activeTabIndex.value >= index) {
    activeTabIndex.value = Math.max(0, activeTabIndex.value - 1);
  }
}

// Methods for SQL execution
async function executerRequete() {
  if (!requeteCourante.value.trim()) {
    erreur.value = 'Veuillez entrer une requête SQL';
    suggestionsErreur.value = [
      'Entrez une requête SQL dans l\'éditeur',
      'Vous pouvez utiliser les exemples proposés dans le menu "Exemples"'
    ];
    return;
  }

  chargement.value = true;
  erreur.value = null;
  resultat.value = null;
  suggestionsErreur.value = [];
  const debut = performance.now();

  try {
    // Ensure query ends with semicolon
    let query = requeteCourante.value.trim();
    if (!query.endsWith(';')) {
      query += ';';
    }

    const reponse = await fetch('http://localhost:3000/executer-requete', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        requeteSql: query
      })
    });

    const donnees = await reponse.json();

    if (donnees.error) {
      throw new Error(donnees.error);
    }

    resultat.value = donnees.resultat;

    // Add to history if successful
    const historiquItem = {
      requete: query,
      resultat: donnees.resultat.message,
      timestamp: Date.now()
    };

    historique.value.unshift(historiquItem);
    sauvegarderHistorique();
  } catch (err) {
    erreur.value = err.message;
    genererSuggestions(err.message);
    console.error('Erreur:', err);
  } finally {
    chargement.value = false;
    tempsExecution.value = Math.round(performance.now() - debut);
  }
}

function formaterRequete() {
  if (!requeteCourante.value.trim()) return;

  // Enhanced SQL formatter
  const keywords = [
    'SELECT', 'FROM', 'WHERE', 'AND', 'OR', 'INSERT', 'INTO', 'VALUES',
    'UPDATE', 'SET', 'DELETE', 'CREATE', 'TABLE', 'ALTER', 'DROP', 'JOIN',
    'LEFT', 'RIGHT', 'INNER', 'OUTER', 'ON', 'GROUP', 'BY', 'ORDER', 'HAVING',
    'LIMIT', 'OFFSET', 'UNION', 'ALL', 'DISTINCT', 'AS'
  ];

  let formattedQuery = requeteCourante.value;

  // Upper case all SQL keywords
  keywords.forEach(keyword => {
    const regex = new RegExp(`\\b${keyword}\\b`, 'gi');
    formattedQuery = formattedQuery.replace(regex, keyword);
  });

  // Add new lines after specific keywords
  const majorKeywords = ['SELECT', 'FROM', 'WHERE', 'GROUP BY', 'HAVING', 'ORDER BY', 'INSERT INTO', 'VALUES', 'DELETE FROM', 'UPDATE', 'SET'];
  majorKeywords.forEach(keyword => {
    const regex = new RegExp(`\\b${keyword}\\b`, 'g');
    formattedQuery = formattedQuery.replace(regex, `\n${keyword}`);
  });

  // Handle commas
  formattedQuery = formattedQuery.replace(/,/g, ',\n  ');

  // Clean up multiple newlines
  formattedQuery = formattedQuery.replace(/\n\s*\n/g, '\n');

  // Handle parentheses
  formattedQuery = formattedQuery.replace(/\(/g, '(\n  ');
  formattedQuery = formattedQuery.replace(/\)/g, '\n)');

  // Add indentation after FROM
  const lines = formattedQuery.split('\n');
  let indentNext = false
  let indentLevel = 0;
  formattedQuery = lines.map(line => {
    if (line.trim().endsWith('(')) {
      indentLevel++;
    } else if (line.trim().startsWith(')')) {
      indentLevel = Math.max(0, indentLevel - 1);
    }

    const indentedLine = '  '.repeat(indentLevel) + line.trim();

    if (line.trim().endsWith('FROM') || line.trim().endsWith('WHERE') ||
      line.trim().endsWith('JOIN') || line.trim().endsWith('ON')) {
      indentNext = true;
    } else if (indentNext) {
      indentNext = false;
      indentLevel++;
    }

    return indentedLine;
  }).join('\n');

  requeteCourante.value = formattedQuery.trim();
}

function effacerRequete() {
  requeteCourante.value = '';
  resultat.value = null;
  erreur.value = null;
}

// Helper methods
function gererTabulation(e) {
  e.preventDefault();
  const start = e.target.selectionStart;
  const end = e.target.selectionEnd;

  requeteCourante.value =
    requeteCourante.value.substring(0, start) +
    '  ' +
    requeteCourante.value.substring(end);

  nextTick(() => {
    e.target.selectionStart = e.target.selectionEnd = start + 2;
  });
}

function afficherSuggestions() {
  if (!requeteCourante.value.trim()) {
    syntaxHints.value = ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE'];
    return;
  }

  const lastWord = requeteCourante.value.split(/\s+/).pop().toUpperCase();
  const hints = [];

  if (lastWord === 'SELECT') {
    hints.push('*', ...tables.value.map(t => t.nom));
  } else if (lastWord === 'FROM') {
    hints.push(...tables.value.map(t => t.nom));
  } else if (lastWord === 'WHERE') {
    hints.push('1=1', ...tables.value.flatMap(t => [`${t.nom}.id`, `${t.nom}.name`]));
  } else if (lastWord === 'INSERT') {
    hints.push('INTO');
  } else if (lastWord === 'UPDATE') {
    hints.push(...tables.value.map(t => t.nom));
  } else if (lastWord === 'DELETE') {
    hints.push('FROM');
  }

  syntaxHints.value = hints.length > 0 ? hints : [];
}

function insererSuggestion(hint) {
  const currentText = requeteCourante.value;
  const words = currentText.split(/\s+/);
  words[words.length - 1] = hint;
  requeteCourante.value = words.join(' ') + ' ';
  syntaxHints.value = [];
  nextTick(() => {
    if (sqlEditor.value) {
      sqlEditor.value.focus();
    }
  });
}

function toggleExamplesMenu() {
  showExamplesMenu.value = !showExamplesMenu.value;
}

function insererExemple(query) {
  requeteCourante.value = query;
  showExamplesMenu.value = false;
  nextTick(() => {
    if (sqlEditor.value) {
      sqlEditor.value.focus();
    }
  });
}

function insererNomTable(tableName) {
  const currentText = requeteCourante.value;
  requeteCourante.value = currentText + tableName;
  nextTick(() => {
    if (sqlEditor.value) {
      sqlEditor.value.focus();
    }
  });
}

function traduireErreur(error) {
  const translations = {
    'syntax error': 'Erreur de syntaxe SQL',
    'table does not exist': 'La table n\'existe pas',
    'column does not exist': 'La colonne n\'existe pas',
    'permission denied': 'Permission refusée'
  };

  for (const [key, value] of Object.entries(translations)) {
    if (error.toLowerCase().includes(key)) {
      return value + ': ' + error;
    }
  }

  return error;
}

function traduireResultat(message) {
  const translations = {
    'query executed successfully': 'Requête exécutée avec succès',
    'rows inserted': 'lignes insérées',
    'rows updated': 'lignes mises à jour',
    'rows deleted': 'lignes supprimées',
    'table created': 'table créée'
  };

  for (const [key, value] of Object.entries(translations)) {
    if (message.toLowerCase().includes(key)) {
      return message.replace(key, value);
    }
  }

  return message;
}

function genererSuggestions(error) {
  const suggestions = [];

  if (error.toLowerCase().includes('syntax error')) {
    suggestions.push(
      'Vérifiez la syntaxe de votre requête',
      'Assurez-vous que tous les mots-clés SQL sont corrects',
      'Vérifiez que votre requête se termine par un point-virgule'
    );
  } else if (error.toLowerCase().includes('table does not exist')) {
    suggestions.push(
      'Vérifiez le nom de la table',
      'Utilisez une des tables disponibles listées à gauche',
      'Les noms de tables peuvent être sensibles à la casse'
    );
  } else if (error.toLowerCase().includes('column does not exist')) {
    suggestions.push(
      'Vérifiez le nom de la colonne',
      'Les noms de colonnes peuvent être sensibles à la casse',
      'Consultez la structure de la table pour voir les colonnes disponibles'
    );
  }

  suggestionsErreur.value = suggestions;
}

// Data export methods
function exporterResultats(format) {
  if (!resultat.value?.donnees) return;

  let content = '';
  const data = resultat.value.donnees;

  if (format === 'csv') {
    // Generate CSV content
    content = data.colonnes.join(',') + '\n';
    content += data.donnees.map(row =>
      data.colonnes.map(col =>
        `"${String(row[col] || '').replace(/"/g, '""')}"`
      ).join(',')
    ).join('\n');

    downloadFile('resultats.csv', content, 'text/csv');
  } else if (format === 'json') {
    // Generate JSON content
    content = JSON.stringify(data.donnees, null, 2);
    downloadFile('resultats.json', content, 'application/json');
  }
}

function downloadFile(filename, content, mimeType) {
  const blob = new Blob([content], { type: mimeType });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

// Database methods
async function chargerListeTables() {
  try {
    const response = await fetch('http://localhost:3000/tables');
    const data = await response.json();
    tables.value = data.tables || [];
  } catch (err) {
    console.error('Erreur lors du chargement des tables:', err);
  }
}

function rafraichirBDD() {
  chargerListeTables();
}

// History methods
function chargerHistorique() {
  const savedHistory = localStorage.getItem('sqlEditorHistory');
  if (savedHistory) {
    try {
      historique.value = JSON.parse(savedHistory);
    } catch (err) {
      console.error('Erreur lors du chargement de l\'historique:', err);
    }
  }
}

function sauvegarderHistorique() {
  localStorage.setItem('sqlEditorHistory', JSON.stringify(historique.value));
}

function chargerRequeteHistorique(query) {
  requeteCourante.value = query;
  nextTick(() => {
    if (sqlEditor.value) {
      sqlEditor.value.focus();
    }
  });
}

function viderHistorique() {
  historique.value = [];
  localStorage.removeItem('sqlEditorHistory');
}

// Utility methods
function formatDate(timestamp) {
  const date = new Date(timestamp);
  return date.toLocaleTimeString() + ' ' + date.toLocaleDateString();
}

function tronquerTexte(text, maxLength) {
  if (text.length <= maxLength) return text;
  return text.substring(0, maxLength) + '...';
}
</script>

<style scoped>
/* Base styles */
#application {
  display: flex;
  flex-direction: column;
  height: 100vh;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  transition: background-color 0.3s, color 0.3s;
}

.en-tete {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  border-bottom: 1px solid #e0e0e0;
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.logo {
  font-size: 2rem;
  font-weight: bold;
  color: #4a6baf;
  background-color: #e0e7ff;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
}

.title-container h1 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
}

.sous-titre {
  margin: 0;
  font-size: 0.9rem;
  color: #666;
}

.theme-button {
  background: none;
  border: 1px solid #ddd;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  cursor: pointer;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.conteneur-principal {
  display: flex;
  flex: 1;
  overflow: visible;
}

.panneau-requete {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 1rem;
  border-right: 1px solid #e0e0e0;
  overflow: visible;
}

.editor-header {
  margin-bottom: 1rem;
}

.editor-header h2 {
  margin: 0 0 0.5rem 0;
  font-size: 1.2rem;
}

.editor-tabs {
  display: flex;
  gap: 0.5rem;
  overflow-x: auto;
  padding-bottom: 0.5rem;
}

.tab-button {
  position: relative;
  background: none;
  border: 1px solid #ddd;
  padding: 0.5rem 1.5rem 0.5rem 1rem;
  border-radius: 0.5rem 0.5rem 0 0;
  cursor: pointer;
  font-size: 0.9rem;
  white-space: nowrap;
}

.tab-button.active {
  background-color: #f0f0f0;
  border-bottom: 1px solid #f0f0f0;
}

.close-tab {
  position: absolute;
  right: 0.5rem;
  top: 50%;
  transform: translateY(-50%);
  cursor: pointer;
  font-size: 1rem;
  line-height: 1;
}

.close-tab:hover {
  color: #f44336;
}

.add-tab {
  background: none;
  border: 1px dashed #ddd;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  cursor: pointer;
  font-size: 0.9rem;
}

.editor-container {
  position: relative;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.zone-saisie {
  flex: 1;
  padding: 1rem;
  border: 1px solid #ddd;
  border-radius: 0.5rem;
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 1rem;
  line-height: 1.5;
  resize: none;
  outline: none;
  tab-size: 2;
}

.syntax-hints {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: white;
  border: 1px solid #ddd;
  border-radius: 0 0 0.5rem 0.5rem;
  max-height: 150px;
  overflow-y: auto;
  z-index: 10;
}

.hint-item {
  padding: 0.5rem 1rem;
  cursor: pointer;
}

.hint-item:hover {
  background-color: #f0f0f0;
}

.controles {
  display: flex;
  gap: 0.5rem;
  margin-top: 1rem;
  flex-wrap: wrap;
}

.bouton {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  cursor: pointer;
  font-size: 0.9rem;
  border: none;
}

.bouton-primaire {
  background-color: #4a6baf;
  color: white;
}

.bouton-secondaire {
  background-color: #e0e7ff;
  color: #4a6baf;
}

.bouton-danger {
  background-color: #ffebee;
  color: #f44336;
}

.bouton-info {
  background-color: #e3f2fd;
  color: #2196f3;
}

.bouton-export {
  background-color: #e8f5e9;
  color: #4caf50;
}

.icon {
  width: 1rem;
  height: 1rem;
}

.examples-dropdown {
  position: relative;
}

.examples-menu {
  position: absolute;
  top: 100%;
  left: 0;
  background-color: white;
  border: 1px solid #ddd;
  border-radius: 0.5rem;
  width: 200px;
  max-height: 300px;
  overflow-y: auto;
  z-index: 10;
}

.exemple-item {
  padding: 0.5rem 1rem;
  cursor: pointer;
}

.exemple-item:hover {
  background-color: #f0f0f0;
}

.panneau-resultats {
  flex: 1;
  padding: 1rem;
  overflow-y: auto;
}

.panneau-resultats h2 {
  margin: 0 0 1rem 0;
  font-size: 1.2rem;
}

.indicateur-chargement {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  height: 100%;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #4a6baf;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }

  100% {
    transform: rotate(360deg);
  }
}

.message-erreur {
  border: 1px solid #ffcdd2;
  background-color: #ffebee;
  border-radius: 0.5rem;
  padding: 1rem;
}

.error-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
  color: #f44336;
}

.error-content pre {
  white-space: pre-wrap;
  margin: 0;
  font-family: 'Consolas', 'Monaco', monospace;
}

.error-suggestions {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #ffcdd2;
}

.error-suggestions h4 {
  margin: 0 0 0.5rem 0;
  font-size: 1rem;
}

.error-suggestions ul {
  margin: 0;
  padding-left: 1.5rem;
}

.contenu-resultat {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.resume-execution {
  border: 1px solid #c8e6c9;
  background-color: #e8f5e9;
  border-radius: 0.5rem;
  padding: 1rem;
}

.success-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
  color: #4caf50;
}

.result-message {
  margin: 0 0 1rem 0;
  font-weight: 500;
}

.success-stats {
  display: flex;
  gap: 1rem;
}

.stat-item {
  display: flex;
  gap: 0.5rem;
}

.stat-label {
  font-weight: 500;
}

.tableau-resultats {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th,
td {
  padding: 0.75rem;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

th {
  background-color: #f5f5f5;
  font-weight: 500;
}

tr:hover {
  background-color: #f5f5f5;
}

.export-options {
  display: flex;
  gap: 0.5rem;
}

.message-vide {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  height: 100%;
  text-align: center;
  color: #666;
}

.message-vide-sub {
  font-size: 0.9rem;
  max-width: 300px;
}

.panneau-lateral {
  width: 300px;
  padding: 1rem;
  border-left: 1px solid #e0e0e0;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.lateral-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.lateral-header h3 {
  margin: 0;
  font-size: 1.1rem;
}

.bouton-refresh {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 0.25rem;
}

.bouton-refresh:hover {
  background-color: #f0f0f0;
}

.liste-tables h4,
.historique h4,
.shortcuts-help h4 {
  margin: 0 0 0.5rem 0;
  font-size: 1rem;
  color: #666;
}

.tables-container {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.table-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem;
  border-radius: 0.25rem;
  cursor: pointer;
}

.table-item:hover {
  background-color: #f0f0f0;
}

.historique-container {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.historique-item {
  padding: 0.5rem;
  border-radius: 0.25rem;
  cursor: pointer;
  border: 1px solid #e0e0e0;
}

.historique-item:hover {
  background-color: #f0f0f0;
}

.historique-time {
  font-size: 0.7rem;
  color: #666;
  margin-bottom: 0.25rem;
}

.historique-query {
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 0.8rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.historique-vide {
  color: #666;
  font-size: 0.9rem;
  text-align: center;
  padding: 1rem 0;
}

.bouton-vider {
  width: 100%;
  background: none;
  border: 1px solid #ffcdd2;
  color: #f44336;
  padding: 0.5rem;
  border-radius: 0.25rem;
  cursor: pointer;
  font-size: 0.8rem;
}

.bouton-vider:hover {
  background-color: #ffebee;
}

.shortcut-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.shortcut-item {
  display: flex;
  justify-content: space-between;
  font-size: 0.8rem;
}

.shortcut-key {
  background-color: #f0f0f0;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  font-family: 'Consolas', 'Monaco', monospace;
}

.shortcut-desc {
  color: #666;
}

/* Dark mode styles */
.dark-mode {
  background-color: #1e1e1e;
  color: #e0e0e0;
}

.dark-mode .en-tete {
  border-bottom-color: #333;
}

.dark-mode .logo {
  color: #a5b4fc;
  background-color: #3730a3;
}

.dark-mode .sous-titre {
  color: #a1a1aa;
}

.dark-mode .theme-button {
  border-color: #444;
  background-color: #333;
  color: #e0e0e0;
}

.dark-mode .panneau-requete,
.dark-mode .panneau-resultats,
.dark-mode .panneau-lateral {
  border-color: #333;
}

.dark-mode .tab-button {
  border-color: #444;
  color: #e0e0e0;
}

.dark-mode .tab-button.active {
  background-color: #333;
  border-bottom-color: #333;
}

.dark-mode .zone-saisie {
  background-color: #252526;
  border-color: #333;
  color: #e0e0e0;
}

.dark-mode .syntax-hints {
  background-color: #252526;
  border-color: #333;
}

.dark-mode .hint-item:hover {
  background-color: #333;
}

.dark-mode .examples-menu {
  background-color: #252526;
  border-color: #333;
}

.dark-mode .exemple-item:hover {
  background-color: #333;
}

.dark-mode .message-erreur {
  border-color: #7f1d1d;
  background-color: #1e1e1e;
}

.dark-mode .error-header {
  color: #f87171;
}

.dark-mode .error-suggestions {
  border-top-color: #7f1d1d;
}

.dark-mode .contenu-resultat {
  border-color: #14532d;
  background-color: #1e1e1e;
}

.dark-mode .success-header {
  color: #4ade80;
}

.dark-mode table {
  border-color: #333;
}

.dark-mode th {
  background-color: #252526;
}

.dark-mode tr:hover {
  background-color: #252526;
}

.dark-mode .message-vide {
  color: #a1a1aa;
}

.dark-mode .table-item:hover,
.dark-mode .historique-item:hover,
.dark-mode .bouton-refresh:hover {
  background-color: #252526;
}

.dark-mode .shortcut-key {
  background-color: #252526;
}

.dark-mode .shortcut-desc {
  color: #a1a1aa;
}

.dark-mode .bouton-vider {
  border-color: #7f1d1d;
  color: #f87171;
}

.dark-mode .bouton-vider:hover {
  background-color: #1e1e1e;
}

/* Responsive adjustments */
@media (max-width: 1200px) {
  .conteneur-principal {
    flex-direction: column;
  }

  .panneau-lateral {
    width: 100%;
    border-left: none;
    border-top: 1px solid #e0e0e0;
  }

  .dark-mode .panneau-lateral {
    border-top-color: #333;
  }
}

@media (max-width: 768px) {
  .en-tete {
    flex-direction: column;
    gap: 1rem;
    padding: 1rem;
  }

  .controles {
    justify-content: center;
  }

  .panneau-requete,
  .panneau-resultats {
    padding: 0.5rem;
  }
}
</style>