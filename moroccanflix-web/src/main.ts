// ================================================================
// REMPLACER ENTIÈREMENT src/main.ts
// ================================================================

import { bootstrapApplication } from '@angular/platform-browser';
import { importProvidersFrom } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

import { AppComponent } from './app/app.component';
import { routes } from './app/app.routes';
import { authInterceptor } from './app/core/interceptors/auth.interceptor';

console.log('🚀 Démarrage de l\'application MoroccanFlix...');

bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor])), // ✅ CRUCIAL
    importProvidersFrom(BrowserAnimationsModule)
  ]
})
.then(() => {
  console.log('✅ Application démarrée avec succès');
})
.catch(err => {
  console.error('❌ Erreur de démarrage:', err);
  
  // Afficher l'erreur sur la page pour debug
  document.body.innerHTML = `
    <div style="
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      color: #E50914;
      font-family: Arial, sans-serif;
      text-align: center;
      background: #141414;
      padding: 20px;
      border-radius: 8px;
      max-width: 500px;
    ">
      <h1>❌ Erreur de démarrage</h1>
      <p style="color: #fff; margin: 10px 0;">${err.message}</p>
      <button onclick="location.reload()" style="
        background: #E50914;
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 4px;
        cursor: pointer;
        margin-top: 10px;
      ">Recharger</button>
    </div>
  `;
});