import { Component, OnInit } from '@angular/core';
import { AlertController, ToastController, ActionSheetController, ModalController } from '@ionic/angular';
import { TaskService } from '../../core/services/task.service';
import { NotificationService } from '../../core/services/notification.service';
import { StorageService } from '../../core/services/storage.service';
import { Task, TaskPriority, TaskStatus } from '../../core/models/task.model';
import { Category } from '../../core/models/category.model';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
  tasks: Task[] = [];
  categories: Category[] = [];
  filteredTasks: Task[] = [];
  
  // Filtres
  selectedCategory = 'all';
  selectedPriority = 'all';
  selectedStatus = 'all';
  searchTerm = '';
  
  // Vue et tri
  viewMode: 'list' | 'grid' | 'calendar' = 'list';
  sortBy: 'dueDate' | 'priority' | 'createdAt' | 'title' = 'dueDate';
  sortOrder: 'asc' | 'desc' = 'asc';
  
  // États de l'interface
  isLoading = false;
  showCompleted = false;
  
  // Statistiques
  stats = {
    total: 0,
    completed: 0,
    pending: 0,
    overdue: 0,
    today: 0
  };

  constructor(
    private taskService: TaskService,
    private notificationService: NotificationService,
    private storageService: StorageService,
    private alertController: AlertController,
    private toastController: ToastController,
    private actionSheetController: ActionSheetController,
    private modalController: ModalController
  ) {}

  ngOnInit() {
    this.loadData();
    this.loadUserPreferences();
  }

  ionViewWillEnter() {
    this.refreshTasks();
  }

  async loadData() {
    this.isLoading = true;
    
    try {
      await Promise.all([
        this.loadTasks(),
        this.loadCategories()
      ]);
      
      this.applyFilters();
      this.updateStats();
    } catch (error) {
      console.error('Erreur lors du chargement des données:', error);
      this.showToast('Erreur lors du chargement des données', 'danger');
    } finally {
      this.isLoading = false;
    }
  }

  async loadTasks() {
    this.tasks = await this.taskService.getTasks();
  }

  async loadCategories() {
    this.categories = await this.taskService.getCategories();
  }

  async loadUserPreferences() {
    const preferences = await this.storageService.get('userPreferences');
    if (preferences) {
      this.viewMode = preferences.viewMode || 'list';
      this.sortBy = preferences.sortBy || 'dueDate';
      this.sortOrder = preferences.sortOrder || 'asc';
      this.showCompleted = preferences.showCompleted || false;
    }
  }

  async saveUserPreferences() {
    const preferences = {
      viewMode: this.viewMode,
      sortBy: this.sortBy,
      sortOrder: this.sortOrder,
      showCompleted: this.showCompleted
    };
    await this.storageService.set('userPreferences', preferences);
  }

  async refreshTasks(event?: any) {
    await this.loadTasks();
    this.applyFilters();
    this.updateStats();
    
    if (event) {
      event.target.complete();
    }
  }

  applyFilters() {
    let filtered = [...this.tasks];

    // Filtre par catégorie
    if (this.selectedCategory !== 'all') {
      filtered = filtered.filter(task => task.categoryId === this.selectedCategory);
    }

    // Filtre par priorité
    if (this.selectedPriority !== 'all') {
      filtered = filtered.filter(task => task.priority === this.selectedPriority);
    }

    // Filtre par statut
    if (this.selectedStatus !== 'all') {
      filtered = filtered.filter(task => task.status === this.selectedStatus);
    }

    // Masquer/afficher les tâches terminées
    if (!this.showCompleted) {
      filtered = filtered.filter(task => task.status !== TaskStatus.COMPLETED);
    }

    // Recherche textuelle
    if (this.searchTerm.trim()) {
      const term = this.searchTerm.toLowerCase().trim();
      filtered = filtered.filter(task =>
        task.title.toLowerCase().includes(term) ||
        task.description?.toLowerCase().includes(term) ||
        task.tags?.some(tag => tag.toLowerCase().includes(term))
      );
    }

    // Tri
    filtered.sort((a, b) => {
      let comparison = 0;
      
      switch (this.sortBy) {
        case 'title':
          comparison = a.title.localeCompare(b.title);
          break;
        case 'priority':
          const priorityOrder = { high: 3, medium: 2, low: 1 };
          comparison = priorityOrder[b.priority] - priorityOrder[a.priority];
          break;
        case 'dueDate':
          if (!a.dueDate && !b.dueDate) comparison = 0;
          else if (!a.dueDate) comparison = 1;
          else if (!b.dueDate) comparison = -1;
          else comparison = new Date(a.dueDate).getTime() - new Date(b.dueDate).getTime();
          break;
        case 'createdAt':
          comparison = new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime();
          break;
      }
      
      return this.sortOrder === 'asc' ? comparison : -comparison;
    });

    this.filteredTasks = filtered;
  }

  updateStats() {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000);

    this.stats = {
      total: this.tasks.length,
      completed: this.tasks.filter(task => task.status === TaskStatus.COMPLETED).length,
      pending: this.tasks.filter(task => task.status === TaskStatus.PENDING).length,
      overdue: this.tasks.filter(task => 
        task.dueDate && 
        new Date(task.dueDate) < today && 
        task.status !== TaskStatus.COMPLETED
      ).length,
      today: this.tasks.filter(task => 
        task.dueDate && 
        new Date(task.dueDate) >= today && 
        new Date(task.dueDate) < tomorrow
      ).length
    };
  }

  async toggleTaskStatus(task: Task) {
    const newStatus = task.status === TaskStatus.COMPLETED 
      ? TaskStatus.PENDING 
      : TaskStatus.COMPLETED;
    
    const updatedTask = { ...task, status: newStatus };
    
    if (newStatus === TaskStatus.COMPLETED) {
      updatedTask.completedAt = new Date().toISOString();
    } else {
      updatedTask.completedAt = undefined;
    }

    try {
      await this.taskService.updateTask(updatedTask);
      await this.refreshTasks();
      
      const message = newStatus === TaskStatus.COMPLETED 
        ? 'Tâche marquée comme terminée' 
        : 'Tâche marquée comme en cours';
      
      this.showToast(message, 'success');
    } catch (error) {
      console.error('Erreur lors de la mise à jour:', error);
      this.showToast('Erreur lors de la mise à jour de la tâche', 'danger');
    }
  }

  async deleteTask(task: Task) {
    const alert = await this.alertController.create({
      header: 'Confirmer la suppression',
      message: `Êtes-vous sûr de vouloir supprimer la tâche "${task.title}" ?`,
      buttons: [
        {
          text: 'Annuler',
          role: 'cancel'
        },
        {
          text: 'Supprimer',
          role: 'destructive',
          handler: async () => {
            try {
              await this.taskService.deleteTask(task.id);
              await this.refreshTasks();
              this.showToast('Tâche supprimée', 'success');
            } catch (error) {
              console.error('Erreur lors de la suppression:', error);
              this.showToast('Erreur lors de la suppression', 'danger');
            }
          }
        }
      ]
    });

    await alert.present();
  }

  async presentTaskActions(task: Task) {
    const actionSheet = await this.actionSheetController.create({
      header: task.title,
      buttons: [
        {
          text: 'Modifier',
          icon: 'create-outline',
          handler: () => {
            this.editTask(task);
          }
        },
        {
          text: task.status === TaskStatus.COMPLETED ? 'Marquer en cours' : 'Marquer terminée',
          icon: task.status === TaskStatus.COMPLETED ? 'radio-button-off-outline' : 'checkmark-circle-outline',
          handler: () => {
            this.toggleTaskStatus(task);
          }
        },
        {
          text: 'Dupliquer',
          icon: 'copy-outline',
          handler: () => {
            this.duplicateTask(task);
          }
        },
        {
          text: 'Supprimer',
          icon: 'trash-outline',
          role: 'destructive',
          handler: () => {
            this.deleteTask(task);
          }
        },
        {
          text: 'Annuler',
          icon: 'close',
          role: 'cancel'
        }
      ]
    });

    await actionSheet.present();
  }

  async duplicateTask(task: Task) {
    const duplicatedTask: Partial<Task> = {
      title: `${task.title} (copie)`,
      description: task.description,
      priority: task.priority,
      categoryId: task.categoryId,
      tags: [...(task.tags || [])],
      status: TaskStatus.PENDING
    };

    try {
      await this.taskService.createTask(duplicatedTask as Task);
      await this.refreshTasks();
      this.showToast('Tâche dupliquée', 'success');
    } catch (error) {
      console.error('Erreur lors de la duplication:', error);
      this.showToast('Erreur lors de la duplication', 'danger');
    }
  }

  editTask(task: Task) {
    // Navigation vers la page d'édition - à implémenter avec le router
    // this.router.navigate(['/task-form', task.id]);
    console.log('Éditer la tâche:', task);
  }

  createTask() {
    // Navigation vers la page de création - à implémenter avec le router
    // this.router.navigate(['/task-form']);
    console.log('Créer une nouvelle tâche');
  }

  onCategoryChange(categoryId: string) {
    this.selectedCategory = categoryId;
    this.applyFilters();
  }

  onPriorityChange(priority: string) {
    this.selectedPriority = priority;
    this.applyFilters();
  }

  onStatusChange(status: string) {
    this.selectedStatus = status;
    this.applyFilters();
  }

  onSearchChange(event: any) {
    this.searchTerm = event.target.value;
    this.applyFilters();
  }

  clearSearch() {
    this.searchTerm = '';
    this.applyFilters();
  }

  async changeViewMode(mode: 'list' | 'grid' | 'calendar') {
    this.viewMode = mode;
    await this.saveUserPreferences();
  }

  async changeSorting(sortBy: typeof this.sortBy) {
    if (this.sortBy === sortBy) {
      this.sortOrder = this.sortOrder === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortBy = sortBy;
      this.sortOrder = 'asc';
    }
    
    this.applyFilters();
    await this.saveUserPreferences();
  }

  async toggleShowCompleted() {
    this.showCompleted = !this.showCompleted;
    this.applyFilters();
    await this.saveUserPreferences();
  }

  resetFilters() {
    this.selectedCategory = 'all';
    this.selectedPriority = 'all';
    this.selectedStatus = 'all';
    this.searchTerm = '';
    this.applyFilters();
  }

  getPriorityColor(priority: TaskPriority): string {
    switch (priority) {
      case TaskPriority.HIGH:
        return 'danger';
      case TaskPriority.MEDIUM:
        return 'warning';
      case TaskPriority.LOW:
        return 'success';
      default:
        return 'medium';
    }
  }

  getPriorityIcon(priority: TaskPriority): string {
    switch (priority) {
      case TaskPriority.HIGH:
        return 'arrow-up-circle';
      case TaskPriority.MEDIUM:
        return 'remove-circle';
      case TaskPriority.LOW:
        return 'arrow-down-circle';
      default:
        return 'help-circle';
    }
  }

  getCategoryName(categoryId: string): string {
    const category = this.categories.find(cat => cat.id === categoryId);
    return category ? category.name : 'Sans catégorie';
  }

  getCategoryColor(categoryId: string): string {
    const category = this.categories.find(cat => cat.id === categoryId);
    return category ? category.color : 'medium';
  }

  isTaskOverdue(task: Task): boolean {
    if (!task.dueDate || task.status === TaskStatus.COMPLETED) {
      return false;
    }
    return new Date(task.dueDate) < new Date();
  }

  isTaskDueToday(task: Task): boolean {
    if (!task.dueDate) {
      return false;
    }
    
    const today = new Date();
    const taskDate = new Date(task.dueDate);
    
    return today.toDateString() === taskDate.toDateString();
  }

  formatDate(dateString: string): string {
    const date = new Date(dateString);
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    if (date.toDateString() === today.toDateString()) {
      return 'Aujourd\'hui';
    } else if (date.toDateString() === tomorrow.toDateString()) {
      return 'Demain';
    } else {
      return date.toLocaleDateString('fr-FR');
    }
  }

  private async showToast(message: string, color: 'success' | 'warning' | 'danger' = 'success') {
    const toast = await this.toastController.create({
      message,
      duration: 2000,
      color,
      position: 'bottom'
    });
    await toast.present();
  }

  // Gestion des gestes
  onTaskSwipe(task: Task, direction: 'left' | 'right') {
    if (direction === 'right') {
      // Swipe droite : marquer comme terminé/en cours
      this.toggleTaskStatus(task);
    } else {
      // Swipe gauche : afficher les actions
      this.presentTaskActions(task);
    }
  }

  // Export des tâches
  async exportTasks() {
    try {
      const dataStr = JSON.stringify(this.tasks, null, 2);
      const dataBlob = new Blob([dataStr], { type: 'application/json' });
      
      // Créer un lien de téléchargement
      const url = window.URL.createObjectURL(dataBlob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `tasks-export-${new Date().toISOString().split('T')[0]}.json`;
      link.click();
      
      window.URL.revokeObjectURL(url);
      this.showToast('Tâches exportées avec succès', 'success');
    } catch (error) {
      console.error('Erreur lors de l\'export:', error);
      this.showToast('Erreur lors de l\'export', 'danger');
    }
  }
}