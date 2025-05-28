// ================================================================
// 1. CORRECTION DU FICHIER app.component.ts
// ================================================================

import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet, Router, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet], // ✅ Ajouter RouterOutlet ici
  template: `
    <div class="app-root" [class]="currentRoute">
      <router-outlet></router-outlet>
    </div>
  `,
  styles: [`
    .app-root {
      min-height: 100vh;
      background: var(--background);
    }

    /* Classes spécifiques aux routes pour des styles contextuels */
    .app-root.welcome {
      /* Styles spécifiques à la page welcome */
    }

    .app-root.auth {
      /* Styles spécifiques aux pages d'authentification */
    }

    .app-root.home {
      /* Styles spécifiques à la page d'accueil */
    }
  `]
})
export class AppComponent implements OnInit {
  title = 'MoroccanFlix';
  currentRoute = '';

  constructor(private router: Router) {}

  ngOnInit(): void {
    // Suivre les changements de route pour appliquer des classes CSS contextuelles
    this.router.events
      .pipe(filter(event => event instanceof NavigationEnd))
      .subscribe((event: NavigationEnd) => {
        this.currentRoute = this.getRouteClass(event.url);
      });
  }

  private getRouteClass(url: string): string {
    if (url === '/' || url === '/welcome') {
      return 'welcome';
    } else if (url.startsWith('/auth')) {
      return 'auth';
    } else if (url.startsWith('/home')) {
      return 'home';
    }
    return '';
  }
}