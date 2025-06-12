# SMS Messenger Technical Interview Guide

## 🎯 Project Overview
This guide covers the core concepts from the SMS Messenger application - a full-stack real-time messaging system built with Rails API backend, Angular frontend, and MongoDB database. Use this to prepare for technical discussions about architecture, design patterns, and implementation details.

---

## 🚂 Ruby on Rails Core Concepts

### 1. **API-Only Rails Application Architecture**
```ruby
# config/application.rb
module MySmsMe
  class Application < Rails::Application
    config.api_only = true
  end
end
```
**Interview Question:** *"Why did you choose API-only Rails instead of full Rails with views?"*
**Answer:** API-only removes unnecessary middleware like view rendering, asset pipeline, and CSRF protection, reducing memory footprint and improving performance for microservice architectures.

### 2. **RESTful Resource Design with Nested Actions**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :messages, only: [:index, :create] do
    collection do
      patch :update_statuses  # Custom collection action
    end
  end
  
  post '/webhooks/twilio/status', to: 'webhooks#twilio_status'
end
```
**Interview Question:** *"How do you handle non-CRUD operations in RESTful design?"*
**Answer:** Use collection or member actions for operations that don't fit standard CRUD. Here, `update_statuses` operates on multiple resources, so it's a collection action.

### 3. **Controller Action Flow and Error Handling**
```ruby
# app/controllers/messages_controller.rb
def create
  begin
    message = Message.create!(message_params.merge(
      user: current_user,
      status: 'sending',
      timestamp: Time.current
    ))
    
    send_sms(message)
    render json: message, status: :created
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
```
**Interview Question:** *"How do you handle transaction rollbacks when external API calls fail?"*
**Answer:** The pattern here creates the record first, then calls external API. For atomic operations, wrap in `ActiveRecord::Base.transaction` or use background jobs for external calls.

### 4. **Service Integration with Error Recovery**
```ruby
# app/controllers/messages_controller.rb
def send_sms(message)
  client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
  
  twilio_message = client.messages.create(**{
    body: message.message_body,
    from: ENV['TWILIO_PHONE_NUMBER'],
    to: message.phone_number
  })
  
  message.update!(
    twilio_sid: twilio_message.sid,
    status: map_twilio_status(twilio_message.status)
  )
rescue Twilio::REST::RestError => e
  message.update!(status: 'failed', error_message: e.message)
  Rails.logger.error "Twilio SMS failed: #{e.message}"
end
```
**Interview Question:** *"How do you handle external API failures gracefully?"*
**Answer:** Catch specific exceptions, update local state appropriately, log errors for debugging, and provide meaningful feedback to users.

### 5. **Environment-Specific Configuration**
```ruby
# config/environments/development.rb vs production.rb
# Development: Skip StatusCallback (localhost unreachable)
if Rails.env.development?
  # Skip status_callback_url for local development
else
  message_params[:status_callback] = "#{request.base_url}/webhooks/twilio/status"
end
```
**Interview Question:** *"How do you handle environment-specific business logic?"*
**Answer:** Use `Rails.env` conditionals for environment-specific behavior. Here, webhooks don't work locally, so we skip them in development and rely on polling instead.

### 6. **Authentication without Devise**
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_user!, except: [:login, :register, :health]
  
  private
  
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    payload = JWT.decode(token, Rails.application.credentials.secret_key_base).first
    @current_user = User.find(payload['user_id'])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
```
**Interview Question:** *"Why implement custom JWT auth instead of using Devise?"*
**Answer:** For API-only apps, custom JWT is lighter weight. Devise includes session management and view helpers we don't need. Custom implementation gives precise control over token structure and validation.

### 7. **CORS Configuration for Cross-Origin Requests**
```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins %r{https://.*\.onrender\.com$}, 'http://localhost:4200'
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```
**Interview Question:** *"How do you handle CORS for both development and production environments?"*
**Answer:** Use regex patterns for production domains and explicit localhost for development. The `%r{}` syntax allows dynamic subdomain matching for cloud deployments.

### 8. **Health Check Endpoint with Dependency Verification**
```ruby
# app/controllers/health_controller.rb
def show
  health_status = {
    status: 'OK',
    timestamp: Time.current,
    services: {
      rails: 'OK',
      mongodb: mongodb_health,
      twilio: twilio_health
    }
  }
  
  render json: health_status
end

private

def mongodb_health
  Message.count
  'OK'
rescue => e
  'ERROR'
end
```
**Interview Question:** *"How do you implement health checks for microservices?"*
**Answer:** Health endpoints should verify all critical dependencies. Return structured data including service status and timestamps for monitoring systems.

### 9. **Background Job Pattern (Conceptual)**
```ruby
# Pattern for status polling (if using Sidekiq)
class MessageStatusUpdateJob < ApplicationJob
  def perform
    messages_pending = Message.where(status: 'sending', twilio_sid: {'$ne' => nil})
    
    messages_pending.each do |message|
      # Check Twilio status and update
      update_message_status(message)
    end
  end
end
```
**Interview Question:** *"How would you handle status updates asynchronously?"*
**Answer:** Use background jobs to poll external APIs, reducing request-response latency. Here, we'd queue jobs to check Twilio status periodically instead of real-time polling.

### 10. **Strong Parameters and Input Validation**
```ruby
# app/controllers/messages_controller.rb
private

def message_params
  params.require(:message).permit(:phone_number, :message_body)
end

# Combined with model validation
# app/models/message.rb
validates :phone_number, presence: true, 
          format: { with: /\A\+?[1-9]\d{1,14}\z/ }
validates :message_body, presence: true, length: { maximum: 250 }
```
**Interview Question:** *"How do you implement defense-in-depth for input validation?"*
**Answer:** Use strong parameters for structure validation, model validations for business rules, and additional sanitization at the service layer.

### 11. **Status Mapping and State Management**
```ruby
# app/controllers/messages_controller.rb
def map_twilio_status(twilio_status)
  case twilio_status
  when 'queued', 'sending'
    'sending'
  when 'sent'
    'sent'
  when 'delivered'
    'delivered'
  when 'failed', 'undelivered'
    'failed'
  else
    'sent' # Default fallback
  end
end
```
**Interview Question:** *"How do you handle external API state mapping?"*
**Answer:** Create explicit mapping functions that translate external states to internal representations. Include fallback defaults for unknown states to prevent application crashes.

---

## 🍃 MongoDB Core Concepts

### 1. **Document-Oriented Schema Design**
```ruby
# app/models/message.rb
class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :phone_number, type: String
  field :message_body, type: String
  field :direction, type: String, default: 'outbound'
  field :status, type: String, default: 'sending'
  field :twilio_sid, type: String
  field :timestamp, type: Time
  
  belongs_to :user, optional: true
end
```
**Interview Question:** *"How does MongoDB schema design differ from relational databases?"*
**Answer:** MongoDB stores complete documents, allowing nested data and flexible schemas. No foreign key constraints - relationships are optional by default. Fields can be added without migrations.

### 2. **Mongoid ODM vs ActiveRecord ORM**
```ruby
# Mongoid query syntax
Message.where(status: 'sending', :twilio_sid.ne => nil)

# Equivalent ActiveRecord (conceptual)
Message.where(status: 'sending').where.not(twilio_sid: nil)
```
**Interview Question:** *"What are the key differences between Mongoid and ActiveRecord?"*
**Answer:** Mongoid uses MongoDB query operators like `$ne`, `$in`. No SQL joins - use embedded documents or manual population. Flexible schema means no migrations, but requires careful validation.

### 3. **Connection Configuration with Environment Variables**
```ruby
# config/mongoid.yml
development:
  clients:
    default:
      uri: <%= ENV['MONGODB_URI'] || 'mongodb://mongodb:27017/my_sms_development' %>
```
**Interview Question:** *"How do you handle database connections across environments?"*
**Answer:** Use environment variables for connection strings, allowing different databases per environment without code changes. Docker Compose uses service names (`mongodb`) for internal networking.

### 4. **Document Validation and Constraints**
```ruby
# app/models/message.rb
validates :phone_number, presence: true, 
          format: { with: /\A\+?[1-9]\d{1,14}\z/ }
validates :message_body, presence: true, length: { maximum: 250 }
validates :direction, inclusion: { in: %w[inbound outbound] }

index({ phone_number: 1, timestamp: -1 })
```
**Interview Question:** *"How do you implement data integrity in MongoDB?"*
**Answer:** Use model validations for business rules, MongoDB indexes for uniqueness constraints, and appropriate data types. Unlike SQL, constraints are enforced at application level.

### 5. **Relationship Design: Embedded vs Referenced**
```ruby
# Current: Referenced relationship
belongs_to :user, optional: true

# Alternative: Embedded user data
field :user_name, type: String
field :user_email, type: String

# vs SQL foreign key (conceptual)
# user_id INTEGER REFERENCES users(id)
```
**Interview Question:** *"When do you embed vs reference documents in MongoDB?"*
**Answer:** Embed when data is always accessed together and has 1:few relationship. Reference for many:many or when data is accessed independently. Here, messages might outlive users, so referencing is appropriate.

### 6. **Query Performance and Indexing**
```ruby
# app/models/message.rb
index({ user_id: 1, timestamp: -1 })  # Compound index for user timeline
index({ status: 1 })                   # Status queries
index({ twilio_sid: 1 }, { unique: true, sparse: true })  # Unique Twilio IDs
```
**Interview Question:** *"How do you optimize MongoDB queries?"*
**Answer:** Create compound indexes matching query patterns. Use `explain()` to analyze query performance. Sparse indexes for optional fields with unique constraints.

### 7. **Aggregation vs Simple Queries**
```ruby
# Simple query for message list
Message.where(user: current_user).desc(:timestamp).limit(50)

# Aggregation for analytics (conceptual)
Message.collection.aggregate([
  { '$match' => { user_id: current_user.id } },
  { '$group' => { 
    _id: '$status', 
    count: { '$sum' => 1 } 
  }}
])
```
**Interview Question:** *"When do you use MongoDB aggregation pipeline?"*
**Answer:** Use simple queries for basic CRUD operations. Aggregation for complex data transformation, grouping, and analytics that would require multiple queries otherwise.

### 8. **Connection Pooling and Concurrency**
```ruby
# config/mongoid.yml
production:
  clients:
    default:
      options:
        min_pool_size: 1
        max_pool_size: 5
        wait_queue_timeout: 5
```
**Interview Question:** *"How do you handle database connections in production?"*
**Answer:** Configure connection pools to balance resource usage vs performance. MongoDB handles concurrent reads well, but writes to same document require careful coordination.

### 9. **Data Migration Strategies**
```ruby
# lib/tasks/migrate_messages.rake
namespace :db do
  desc "Add direction field to existing messages"
  task migrate_direction: :environment do
    Message.where(direction: nil).update_all(direction: 'outbound')
  end
end
```
**Interview Question:** *"How do you handle schema changes in MongoDB?"*
**Answer:** No formal migrations like SQL. Use Rake tasks for data transformations. MongoDB's flexible schema allows gradual field additions with default values.

### 10. **Error Handling and Validation**
```ruby
# app/controllers/messages_controller.rb
begin
  message = Message.create!(message_params)
rescue Mongoid::Errors::Validations => e
  render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
rescue Mongoid::Errors::DocumentNotFound => e
  render json: { error: 'Message not found' }, status: :not_found
end
```
**Interview Question:** *"How do you handle MongoDB-specific errors?"*
**Answer:** Catch Mongoid-specific exceptions for validation and document errors. MongoDB connection errors should be handled at the infrastructure level with retries and failover.

### 11. **Bulk Operations and Performance**
```ruby
# Efficient bulk update for status changes
def update_statuses
  updates = messages_to_update.map do |message|
    {
      update_one: {
        filter: { _id: message.id },
        update: { '$set' => { status: new_status, updated_at: Time.current } }
      }
    }
  end
  
  Message.collection.bulk_write(updates)
end
```
**Interview Question:** *"How do you handle bulk operations efficiently in MongoDB?"*
**Answer:** Use `bulk_write` for multiple operations in single request. Reduces network round trips and improves performance for batch updates.

---

## 🅰️ Angular Core Concepts

### 1. **Standalone Components Architecture**
```typescript
// src/app/chat/chat.component.ts
@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './chat.component.html',
  styleUrls: ['./chat.component.scss']
})
export class ChatComponent implements OnInit, OnDestroy {
```
**Interview Question:** *"What are the benefits of standalone components over NgModules?"*
**Answer:** Standalone components reduce bundle size through tree-shaking, simplify dependency management, and enable lazy loading at component level. Better for micro-frontends and component libraries.

### 2. **Reactive Programming with Observables**
```typescript
// src/app/chat/chat.component.ts
ngOnInit() {
  this.loadMessages();
  
  // Polling for status updates
  this.statusUpdateSubscription = interval(30000).subscribe(() => {
    this.messageService.updateMessageStatuses().subscribe();
  });
}

ngOnDestroy() {
  this.statusUpdateSubscription?.unsubscribe();
}
```
**Interview Question:** *"How do you prevent memory leaks with observables?"*
**Answer:** Always unsubscribe in `ngOnDestroy`. Use operators like `takeUntil()` with a destroy subject, or `async` pipe in templates for automatic subscription management.

### 3. **HTTP Client with Error Handling**
```typescript
// src/app/services/message.service.ts
sendMessage(phoneNumber: string, messageBody: string): Observable<any> {
  const token = localStorage.getItem('authToken');
  const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);
  
  return this.http.post<any>(`${this.apiUrl}/messages`, {
    message: { phone_number: phoneNumber, message_body: messageBody }
  }, { headers }).pipe(
    catchError(this.handleError)
  );
}

private handleError(error: HttpErrorResponse) {
  let errorMessage = 'An unknown error occurred';
  if (error.error?.error) {
    errorMessage = error.error.error;
  }
  return throwError(() => errorMessage);
}
```
**Interview Question:** *"How do you implement centralized error handling in Angular?"*
**Answer:** Use HTTP interceptors for global error handling, and service-level error handlers for specific cases. Return user-friendly messages while logging technical details.

### 4. **Form Validation and State Management**
```typescript
// src/app/chat/chat.component.ts
validatePhone(): void {
  this.phoneError = this.validationService.validatePhoneNumber(this.phoneNumber) || '';
}

get isFormValidForTemplate(): boolean {
  return !this.phoneError && !this.messageError;
}

sendMessage(): void {
  this.validatePhone();
  this.validateMessage();
  
  if (!this.isFormValidForTemplate) {
    return;
  }
  // ... send logic
}
```
**Interview Question:** *"How do you handle form validation without reactive forms?"*
**Answer:** Use template-driven forms with custom validation methods. Separate validation logic into services for reusability. Use getters for template bindings to avoid change detection issues.

### 5. **Service Injection and Dependency Management**
```typescript
// src/app/services/validation.service.ts
@Injectable({
  providedIn: 'root'
})
export class ValidationService {
  validatePhoneNumber(phoneNumber: string): string | null {
    const phone = phoneNumber.trim();
    
    if (!phone) {
      return 'Phone number is required';
    }
    
    const basicPattern = /^\+?[1-9]\d{1,14}$/;
    if (!basicPattern.test(phone.replace(/[\s\-\(\)]/g, ''))) {
      return 'Must be a valid phone number';
    }
    
    return null;
  }
}
```
**Interview Question:** *"What's the difference between `providedIn: 'root'` and module providers?"*
**Answer:** `providedIn: 'root'` creates singleton services available app-wide with tree-shaking. Module providers create instances scoped to that module, useful for feature-specific services.

### 6. **Environment Configuration Management**
```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000'
};

// src/environments/environment.prod.ts
export const environment = {
  production: true,
  apiUrl: 'https://my-sms-backend.onrender.com'
};
```
**Interview Question:** *"How do you handle different API endpoints across environments?"*
**Answer:** Use Angular environment files for build-time configuration. The build process replaces environment files based on the target. For runtime config, use APP_INITIALIZER with config services.

### 7. **Component Communication and State Updates**
```typescript
// src/app/chat/chat.component.ts
sendMessage(): void {
  this.messageService.sendMessage(this.phoneNumber, this.messageBody)
    .subscribe({
      next: (response) => {
        this.messages.unshift(response);  // Optimistic update
        this.messageBody = '';
        this.phoneNumber = '';
      },
      error: (error) => {
        console.error('Failed to send message:', error);
        // Handle error state
      }
    });
}
```
**Interview Question:** *"How do you implement optimistic updates in Angular?"*
**Answer:** Update local state immediately, then handle server response. If server fails, revert local changes. This provides better UX but requires careful error handling and state synchronization.

### 8. **Lifecycle Hooks and Resource Management**
```typescript
// src/app/chat/chat.component.ts
export class ChatComponent implements OnInit, OnDestroy {
  private statusUpdateSubscription?: Subscription;
  
  ngOnInit() {
    this.loadMessages();
    this.startStatusPolling();
  }
  
  ngOnDestroy() {
    this.statusUpdateSubscription?.unsubscribe();
  }
  
  private startStatusPolling() {
    this.statusUpdateSubscription = interval(30000)
      .pipe(takeUntil(this.destroy$))
      .subscribe(() => this.updateStatuses());
  }
}
```
**Interview Question:** *"Which lifecycle hooks are most critical for resource management?"*
**Answer:** `ngOnInit` for setup, `ngOnDestroy` for cleanup. Also `ngOnChanges` for input changes, and `ngAfterViewInit` for DOM-dependent operations.

### 9. **Template Binding and Change Detection**
```typescript
// Template binding patterns
// src/app/chat/chat.component.html
<button 
  [disabled]="!isFormValidForTemplate || isCharacterLimitExceeded()"
  (click)="sendMessage()">
  Send Message
</button>

<div *ngFor="let message of messages" 
     [class]="'message-status-' + message.status">
  <span [class]="'status-' + message.status">
    {{ getStatusDisplayText(message.status) }}
  </span>
</div>
```
**Interview Question:** *"How do you avoid performance issues with method calls in templates?"*
**Answer:** Use getters or properties instead of methods for frequently accessed data. Methods in templates trigger on every change detection cycle. Use `OnPush` change detection for performance-critical components.

### 10. **HTTP Interceptors and Authentication**
```typescript
// src/app/services/auth.service.ts (conceptual)
@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const token = localStorage.getItem('authToken');
    
    if (token) {
      const authReq = req.clone({
        headers: req.headers.set('Authorization', `Bearer ${token}`)
      });
      return next.handle(authReq);
    }
    
    return next.handle(req);
  }
}
```
**Interview Question:** *"How do you implement automatic token attachment in Angular?"*
**Answer:** Use HTTP interceptors to modify outgoing requests. Clone requests to add headers. Handle token refresh and retry failed requests with updated tokens.

### 11. **Build Optimization and Production Configuration**
```dockerfile
# Dockerfile multi-stage build
FROM node:lts-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist/my-sms-fe /usr/share/nginx/html
```
**Interview Question:** *"How do you optimize Angular applications for production?"*
**Answer:** Use `ng build --configuration production` for tree-shaking and minification. Implement lazy loading, use `OnPush` change detection, and configure proper caching headers. Multi-stage Docker builds reduce image size.

### 12. **Real-time Data Updates**
```typescript
// Polling strategy for real-time updates
private updateStatuses() {
  this.messageService.updateMessageStatuses().subscribe({
    next: (updatedMessages) => {
      updatedMessages.forEach(updated => {
        const index = this.messages.findIndex(m => m.id === updated.id);
        if (index !== -1) {
          this.messages[index] = { ...this.messages[index], ...updated };
        }
      });
    }
  });
}
```
**Interview Question:** *"How would you implement real-time updates without WebSockets?"*
**Answer:** Use polling with intervals, long-polling, or Server-Sent Events. Polling is simpler but less efficient. For this SMS app, 30-second intervals balance UX and server load since SMS delivery isn't instant.

---

## 🎯 Integration Concepts

### **Full-Stack Data Flow**
```
Frontend Angular → HTTP Request → Rails API → Twilio API → Database Update → Status Polling → UI Update
```

### **Key Technical Decisions Made:**
1. **API-only Rails** for microservice architecture
2. **MongoDB** for flexible message schema
3. **JWT Authentication** for stateless API
4. **Polling over WebSockets** for simplicity
5. **Docker Compose** for development environment

### **Common Follow-up Questions:**
- "How would you scale this to handle 1M messages/day?"
- "What would you change for real-time requirements?"
- "How would you implement message threading/conversations?"
- "What monitoring and logging would you add?"
- "How would you handle message delivery failures?"

---

*Use specific code examples from this project to demonstrate your understanding of these concepts. Practice explaining the trade-offs and architectural decisions you made.*