-- Full DROP and CREATE script for sproject_manage_db
-- WARNING: This will DELETE any existing data in the database named below.
DROP DATABASE IF EXISTS `sproject_manage_db`;
CREATE DATABASE `sproject_manage_db` CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
USE `sproject_manage_db`;

-- 2) users table
CREATE TABLE `users` (
  `id` VARCHAR(64) NOT NULL,
  `userId` VARCHAR(64) NULL,
  `name` VARCHAR(255) NULL,
  `email` VARCHAR(255) NULL,
  `email_verified` DATETIME NULL,
  `password` VARCHAR(255) NULL,
  `image` VARCHAR(255) NULL,
  `office` VARCHAR(255) NULL,
  `phone` VARCHAR(255) NULL,
  `isActive` TINYINT(1) NOT NULL DEFAULT 1,
  `programme` ENUM('COMPUTER_SCIENCE','INFORMATION_TECHNOLOGY_SYSTEMS','SOFTWARE_DEVELOPMENT','MULTIMEDIA_AND_WEB_DEVELOPMENT','MOBILE_COMPUTING_AND_APPLICATIONS','WEB_COMPUTING') NULL,
  `role` ENUM('STUDENT','SUPERVISOR','COORDINATOR','ADMIN') NOT NULL DEFAULT 'STUDENT',
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_userId_unique` (`userId`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_phone_unique` (`phone`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3) projects table
CREATE TABLE `projects` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `status` ENUM('PENDING','APPROVED','REJECTED','COMPLETED') NOT NULL DEFAULT 'PENDING',
  `studentId` VARCHAR(64) NULL,
  `supervisorId` VARCHAR(64) NOT NULL,
  `dateCreated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dateUpdated` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `projects_studentId_unique` (`studentId`),
  KEY `projects_supervisorId_idx` (`supervisorId`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4) accounts table (next-auth)
CREATE TABLE `accounts` (
  `id` VARCHAR(64) NOT NULL,
  `user_id` VARCHAR(64) NOT NULL,
  `type` VARCHAR(255) NOT NULL,
  `provider` VARCHAR(255) NOT NULL,
  `provider_account_id` VARCHAR(255) NOT NULL,
  `refresh_token` TEXT NULL,
  `access_token` TEXT NULL,
  `expires_at` INT NULL,
  `token_type` VARCHAR(255) NULL,
  `scope` VARCHAR(255) NULL,
  `id_token` TEXT NULL,
  `session_state` VARCHAR(255) NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `accounts_provider_providerAccountId_unique` (`provider`,`provider_account_id`),
  KEY `accounts_userId_idx` (`user_id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5) sessions table (next-auth)
CREATE TABLE `sessions` (
  `id` VARCHAR(64) NOT NULL,
  `session_token` VARCHAR(255) NOT NULL,
  `user_id` VARCHAR(64) NOT NULL,
  `expires` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sessions_session_token_unique` (`session_token`),
  KEY `sessions_userId_idx` (`user_id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6) deadlines table
CREATE TABLE `deadlines` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `coordinatorId` VARCHAR(64) NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `deadlineDate` DATETIME NOT NULL,
  `isSubmittable` TINYINT(1) NOT NULL DEFAULT 0,
  `dateCreated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dateUpdated` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `deadlines_coordinator_idx` (`coordinatorId`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7) announcements table
CREATE TABLE `announcements` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `coordinatorId` VARCHAR(64) NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `dateCreated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dateUpdated` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `announcements_coordinator_idx` (`coordinatorId`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8) comments table
CREATE TABLE `comments` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `comment` TEXT NULL,
  `projectId` INT NULL,
  `userId` VARCHAR(64) NULL,
  `dateCreated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `comments_project_idx` (`projectId`),
  KEY `comments_user_idx` (`userId`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9) submissions table
CREATE TABLE `submissions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `userId` VARCHAR(64) NOT NULL,
  `deadlineId` INT NOT NULL,
  `projectId` INT NOT NULL,
  `fileURL` VARCHAR(2048) NOT NULL,
  `description` TEXT NULL,
  `status` VARCHAR(255) NOT NULL,
  `dateSubmitted` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dateUpdated` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `submissions_userId_idx` (`userId`),
  KEY `submissions_deadlineId_idx` (`deadlineId`),
  KEY `submissions_projectId_idx` (`projectId`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10) feedbacks table
CREATE TABLE `feedbacks` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `supervisorId` VARCHAR(64) NOT NULL,
  `submissionId` INT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `dateSubmitted` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dateUpdated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `feedbacks_supervisor_idx` (`supervisorId`),
  KEY `feedbacks_submission_idx` (`submissionId`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11) verification_tokens table
CREATE TABLE `verification_tokens` (
  `identifier` VARCHAR(255) NOT NULL,
  `token` VARCHAR(255) NOT NULL,
  `expires` DATETIME NOT NULL,
  PRIMARY KEY (`identifier`,`token`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12) Add foreign keys (separate to avoid ordering issues)
ALTER TABLE `projects`
  ADD CONSTRAINT `projects_supervisor_fk` FOREIGN KEY (`supervisorId`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `projects`
  ADD CONSTRAINT `projects_student_fk` FOREIGN KEY (`studentId`) REFERENCES `users`(`userId`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `accounts`
  ADD CONSTRAINT `accounts_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sessions`
  ADD CONSTRAINT `sessions_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `deadlines`
  ADD CONSTRAINT `deadlines_coordinator_fk` FOREIGN KEY (`coordinatorId`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `announcements`
  ADD CONSTRAINT `announcements_coordinator_fk` FOREIGN KEY (`coordinatorId`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `comments`
  ADD CONSTRAINT `comments_project_fk` FOREIGN KEY (`projectId`) REFERENCES `projects`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `comments`
  ADD CONSTRAINT `comments_user_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `submissions`
  ADD CONSTRAINT `submissions_user_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`userId`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `submissions`
  ADD CONSTRAINT `submissions_deadline_fk` FOREIGN KEY (`deadlineId`) REFERENCES `deadlines`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `submissions`
  ADD CONSTRAINT `submissions_project_fk` FOREIGN KEY (`projectId`) REFERENCES `projects`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `feedbacks`
  ADD CONSTRAINT `feedbacks_supervisor_fk` FOREIGN KEY (`supervisorId`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `feedbacks`
  ADD CONSTRAINT `feedbacks_submission_fk` FOREIGN KEY (`submissionId`) REFERENCES `submissions`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 13) Prisma migrations table (optional)
CREATE TABLE IF NOT EXISTS `_prisma_migrations` (
  `id` VARCHAR(255) NOT NULL,
  `checksum` VARCHAR(255) NOT NULL,
  `finished_at` DATETIME DEFAULT NULL,
  `migration_name` VARCHAR(255) NOT NULL,
  `logs` TEXT DEFAULT NULL,
  `rolled_back_at` DATETIME DEFAULT NULL,
  `started_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Done. The database sproject_manage_db has been recreated.
-- Update your project's DATABASE_URL to: mysql://<user>:<pass>@127.0.0.1:3306/sproject_manage_db
