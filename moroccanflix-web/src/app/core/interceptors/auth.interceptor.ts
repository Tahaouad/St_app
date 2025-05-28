// ================================================================
// 5. CORRECTION DU FICHIER src/app/core/interceptors/auth.interceptor.ts
// ================================================================

import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { AuthService } from '../services/auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  // Ajouter le token à toutes les requêtes si disponible
  const token = authService.getToken();
  
  let authReq = req;
  if (token) {
    authReq = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
  } else {
    authReq = req.clone({
      setHeaders: {
        'Content-Type': 'application/json'
      }
    });
  }

  return next(authReq).pipe(
    catchError((error) => {
      // Gérer les erreurs d'authentification
      if (error.status === 401 || error.status === 403) {
        authService.logout();
        router.navigate(['/auth/login']);
      }
      
      return throwError(() => error);
    })
  );
};